#!/bin/bash
#
# SSH-SETUP by Christopher Dobler 2015
#
# USAGE:  
#   ssh-setup user host friendly password

#create ssh key
echo "Generating ssh key for $2"
echo "User Name: $1"
echo "Friendly Name: $3"
mkdir ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/$2_rsa -N ''

#//////////////////create user

if ! type "sshpass" > /dev/null; then
	echo "sshpass not detected. Attempting to install.."
  if type "yum" > /dev/null; then
  	echo "RHEL/CentOS OS Detected"
	  yum install sshpass
	fi
  if type "apt-get" > /dev/null; then
  	echo "Ubuntu/Deb OS Detected"
	  sudo apt-get install sshpass
	fi
fi

echo ""
echo "Creating .ssh directory on remote server"
# ssh "$1@$2" -p$4 bash -c "'
export SSHPASS="$4"
sshpass -e ssh -oBatchMode=no "$1@$2" bash -c "'
	mkdir ~/.ssh
	'"
touch ~/.ssh/config
touch ~/.aliases

echo ""
echo "Inserting new key into remote server"
echo `cat ~/.ssh/$2_rsa.pub | sshpass -e ssh -o BatchMode=no $1@$2 "cat >> ~/.ssh/authorized_keys"`

echo ""
echo "Adding quick access alias to new remote"

if hash gsed 2>/dev/null; then
        echo `gsed -i "1s/^/alias $3='ssh -2 -p 22 $1@$2' \n/" ~/.aliases`
        echo `gsed -i "1s/^/Host $2\n	IdentityFile ~\/.ssh\/$2_rsa\n/" ~/.ssh/config`
else
        echo `sed -i "1s/^/alias $3='ssh -2 -p 22 $1@$2' \n/" ~/.aliases` 
        echo `sed -i "1s/^/Host $2\n   IdentityFile ~\/.ssh\/$2_rsa" ~/.ssh/config`
fi
