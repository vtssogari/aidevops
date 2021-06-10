sudo mkdir -p /etc/docker 
sudo touch /etc/docker/daemon.json
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["http://192.168.1.214:8181"],
  "insecure-registries" : ["192.168.1.214:8181"]
}
EOF
sudo systemctl daemon-reload && sudo systemctl restart docker
