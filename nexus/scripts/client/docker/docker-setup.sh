sudo tee /etc/docker/daemon.json <<EOF
{
  "insecure-registries" : ["nexus:8181"]
}
EOF
sudo systemctl daemon-reload && sudo systemctl restart docker
