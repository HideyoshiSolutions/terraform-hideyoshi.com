echo -e "\n${extra_key}" >> /home/ubuntu/.ssh/authorized_keys

echo "export TERM='xterm-256color'" > .profile;


curl -sfL https://get.k3s.io | \
        INSTALL_K3S_EXEC="agent" \
        K3S_TOKEN="${k3s_token}" \
        sh -s - --server "${k3s_url}:6443"