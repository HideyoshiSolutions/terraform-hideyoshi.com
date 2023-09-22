#!/bin/bash -xe


echo -e "\n${extra_key}" >> /home/ubuntu/.ssh/authorized_keys;

echo -e "export TERM='xterm-256color'" >> /home/ubuntu/.profile;

su ubuntu -i << EOF
# curl -sfL https://get.k3s.io | \
#         K3S_TOKEN="${k3s_token}" sh -'
echo "HERE" >> /home/ubuntu/test.txt
EOF