#!/bin/bash
#
# SSH-LAUNCHER by Christopher Dobler 2015
#
# USAGE:  
#   ssh-launcher user host password connecting_ssh friendly

connecting_ssh_friendly_default="someserver-083"
remote_host_default="someserver-083.server.com"
remote_user_default="root"
remote_pass_default=""
remote_key_default="some_key.rsa"
reply_default="Y"

if ! [ -z "$2" ]; then
	remote_host_default=$2
fi
if ! [ -z "$1" ]; then
	remote_user_default=$1
fi
if ! [ -z "$3" ]; then
	remote_pass_default=$3
fi
if ! [ -z "$4" ]; then
	connecting_ssh_default=$4
fi
if ! [ -z "$5" ]; then
	connecting_ssh_friendly_default=$5
fi

if ! type "sshpass" > /dev/null; then
  # install sshpass here
  if type "yum" > /dev/null; then
	  yum install sshpass
	  exit
	fi
  if type "apt-get" > /dev/null; then
	  apt-get install sshpass
	  exit
	fi
  exit
fi

echo "Before running this tool you should go into your local or public DNS server and add an A record for the ip of the machine."
echo 

read -p "Enter the remote host name [$remote_host_default]: " remote_host
remote_host=${remote_host:-$remote_host_default}
read -p "Enter the user name for the host '$remote_host' [$remote_user_default]: " remote_user
remote_user=${remote_user:-$remote_user_default}
read -p "Enter the friendly name for connecting to the host '$remote_host' [$connecting_ssh_friendly_default]: " connecting_ssh_friendly
connecting_ssh_friendly=${connecting_ssh_friendly:-$connecting_ssh_friendly_default}
read -p "Do you have a security key for '$remote_user'? Y/N []: " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	read -p "Your security key must be located in the '~/.ssh' directory. Enter the name of the key [$remote_key_default]: " remote_key
	remote_key=${remote_key:-$remote_key_default}

	echo ""
	echo "Adding quick access alias to new remote"

	if hash gsed 2>/dev/null; then
	        echo `gsed -i "1s/^/alias $connecting_ssh_friendly='ssh -2 -p 22 $remote_user@$remote_host' \n/" ~/.aliases`
	        echo `gsed -i "1s/^/Host $remote_host\n	IdentityFile ~\/.ssh\/$remote_key\n/" ~/.ssh/config`
	else
	        echo `sed -i "1s/^/alias $connecting_ssh_friendly='ssh -2 -p 22 $remote_user@$remote_host' \n/" ~/.aliases` 
	        echo `sed -i "1s/^/Host $remote_host\n   IdentityFile ~\/.ssh\/$remote_key" ~/.ssh/config`
	fi

	echo "Locking file permissions down"
	echo
	chmod 0600 "~\/.ssh\/$remote_key"

else
	remote_user=${remote_user:-$remote_user_default}
	read -p "Enter the password for the remote user '$remote_user@$remote_host' [$remote_pass_default]: " remote_password
	remote_password=${remote_password:-$remote_pass_default}
	read -p "does this user exist already? Y/N []" -n 1 -r
	echo    # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		echo
	    read -p "Enter the admin user for the remote host: " remote_admin_user
	    read -p "Enter the admin password for the remote user '$remote_admin_user': " remote_admin_password
			sshpass -p$remote_admin_password ssh -o StrictHostKeyChecking=no "$remote_admin_user@$remote_host" bash -c "'
			useradd -p$remote_password $remote_user
			echo \"$remote_user ALL=(ALL:ALL) ALL\" | (EDITOR=\"tee -a\" visudo)
			exit
		'"
	fi

	ssh "$remote_user@$remote_host" 'bash -s' < ~/talents/SSH-Remote-Deploy/ssh-setup.sh $remote_user $remote_host $connecting_ssh_friendly_default $remote_password
fi
