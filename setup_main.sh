echo -e "\n${extra_key}" >> /home/ubuntu/.ssh/authorized_keys

echo "export TERM='xterm-256color'" > .profile;


curl -sfL https://get.k3s.io | \
        K3S_TOKEN="${k3s_token}" \
        sh -