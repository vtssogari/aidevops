sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["http://nexus:8181"]
}
EOF
sudo systemctl daemon-reload && sudo systemctl restart docker
