#!/bin/bash

# Setting up swap space
sudo fallocate -l 2G /swapfile
sudo mkswap /swapfile
sudo chmod 600 /swapfile
sudo swapon /swapfile


# Configuring ssh keys
echo -e "${extra_key}" >> /home/ubuntu/.ssh/authorized_keys;
echo -e "${terraform_key}" >> /home/ubuntu/.ssh/authorized_keys;

echo "export TERM='xterm-256color';" > /home/ubuntu/.profile;

exit 0;