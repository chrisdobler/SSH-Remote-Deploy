#!/bin/bash
#
# SSH-LAUNCHER by Christopher Dobler 2015
#
# USAGE:  
#   ssh-launcher user host password connecting_ssh friendly

connecting_ssh_default="root@localhost"
remote_host_default="server.com"
remote_user_default="root"
remote_pass_default=""
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

read -p "Enter the connecting user and host (ie. root@localhost): " connecting_ssh
echo

read -p "Enter the remote host name (ie. remotehost.com): " remote_host
read -p "Enter the user name for the host '$remote_host': " remote_user
read -p "Enter the password for the remote user '$remote_user@$remote_host': " remote_password
read -p "does this user exist already? " -n 1 -r
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


# ssh "$connecting_ssh" 'bash -s' < ~/talents/SSH-Remote-Deploy/ssh-setup.sh $1 $2 $3

