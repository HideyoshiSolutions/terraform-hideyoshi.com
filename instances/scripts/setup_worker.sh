#!/bin/bash -xe


echo -e "\n${extra_key}" >> /home/ubuntu/.ssh/authorized_keys;

echo "export TERM='xterm-256color'" > /home/ubuntu/.profile;

su ubuntu -i << EOF
# curl -sfL https://get.k3s.io | \
#         INSTALL_K3S_EXEC="agent" \
#         K3S_TOKEN="${k3s_token}" \
#         sh -s - --server ${k3s_cluster_ip}
echo "HERE" >> /home/ubuntu/test.txt
EOF