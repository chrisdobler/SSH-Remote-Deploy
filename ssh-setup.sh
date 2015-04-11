#!/bin/bash
#
# SSH-SETUP by Christopher Dobler 2015
#
# USAGE:  
#   ssh-setup user host friendly

#create ssh key
echo "Generating ssh key for $2"
echo "User Name: $1"
echo "Friendly Name: $3"
mkdir ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/$2_rsa
if ! type "sshpass" > /dev/null; then
	yum install sshpass
fi

echo ""
echo "Creating .ssh directory on remote server"
echo `ssh $1@$2 "mkdir ~/.ssh;"`

echo ""
echo "Inserting new key into remote server"
echo `cat ~/.ssh/$2_rsa.pub | ssh $1@$2 "cat >> ~/.ssh/authorized_keys"`

echo ""
echo "Adding quick access alias to new remote"

if hash gsed 2>/dev/null; then
        echo `gsed -i "1s/^/alias $3='ssh -2 -p 22 $1@$2' \n/" ~/.aliases`
        echo `gsed -i "1s/^/Host $2\n	IdentityFile ~\/.ssh\/$2_rsa\n/" ~/.ssh/config`
else
        echo `sed -i "1s/^/alias $3='ssh -2 -p 22 $1@$2' \n/" ~/.aliases` 
        echo `sed -i "1s/^/Host $2\n   IdentityFile ~\/.ssh\/$2_rsa" ~/.ssh/config`
fi
