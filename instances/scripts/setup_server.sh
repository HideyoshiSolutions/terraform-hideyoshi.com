#!/bin/bash

# Setting up swap space
fallocate -l 2G /swapfile
mkswap /swapfile
chmod 600 /swapfile
swapon /swapfile


# Configuring ssh keys
echo -e "${extra_key}" >> /home/ubuntu/.ssh/authorized_keys;
echo -e "${terraform_key}" >> /home/ubuntu/.ssh/authorized_keys;

echo "export TERM='xterm-256color';" > /home/ubuntu/.profile;

exit 0;