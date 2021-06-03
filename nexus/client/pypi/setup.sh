mkdir -p ~/.config/pip/pip.conf

sudo cat <<EOF | sudo tee ~/.config/pip/pip.conf
[global]
index = http://nexus:8081/repository/pypi-proxy/pypi
index-url = http://nexus:8081/repository/pypi-proxy/simple
trusted-host = nexus
EOF
 

