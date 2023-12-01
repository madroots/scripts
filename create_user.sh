#!/bin/bash

# Check if any arguments are provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <username1> [username2] [username3] ..."
    exit 1
fi

# Create user
for i in "$@"; do
    echo "Creating user: $i"
    sudo adduser $i

    echo "Adding user to sudo group"
    sudo usermod -aG sudo $i

    echo "Creating ssh folder and authorized_keys"
    sudo -H -u $i bash -c 'mkdir -p /home/"$0"/.ssh' $i
    sudo -H -u $i bash -c 'chmod 700 /home/"$0"/.ssh/' $i
    sudo -H -u $i bash -c 'touch /home/"$0"/.ssh/authorized_keys' $i
    sudo -H -u $i bash -c 'chmod 600 /home/"$0"/.ssh/authorized_keys' $i
done
