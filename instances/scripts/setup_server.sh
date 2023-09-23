#!/bin/bash


echo -e "\n${extra_key}" >> /home/ubuntu/.ssh/authorized_keys;

echo "export TERM='xterm-256color';" > /home/ubuntu/.profile;

exit 0;