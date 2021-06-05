
# Register Redhat 7 =============================================================
sudo subscription-manager register --username vtssogari --password Love@1224 --auto-attach

# Add repos =====================================================
sudo subscription-manager repos --enable "rhel-*-extras-rpms"
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum repolist

# docker install =====================================================
sudo yum install -y vim git yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# nexus install =====================================================
docker volume create --name nexus-data
docker run -d -p 8081:8081 --name nexus -v nexus-data:/nexus-data sonatype/nexus3

# deepops apply these to all nodes =============================================================
sudo subscription-manager repos --enable rhel-7-server-optional-rpms --enable rhel-server-rhscl-7-rpms
sudo yum -y install @development
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install epel-release
git clone https://github.com/NVIDIA/deepops.git

# install deepops ==================
cd deepops
./scripts/setup.sh 

# Edit Inventory ===================
master      ansible_host=192.168.1.232
gpu         ansible_host=192.168.1.248
worker1     ansible_host=192.168.1.249
worker2     ansible_host=192.168.1.236

# edit ===================
vim ./roles/openshift/tasks/main.yml

# install openshift python client for k8s_raw module
	ignore_errors: yes 

# Install =============================================================
ansible-playbook -l k8s-cluster playbooks/k8s-cluster.yml

# enable Docker GPU ==============================================================================

#Systemd drop-in file

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --host=fd:// --add-runtime=nvidia=/usr/bin/nvidia-container-runtime --insecure-registry=nexus:8484 --registry-mirror=http://nexus:8484
EOF

sudo systemctl daemon-reload && sudo systemctl restart docker

# run docker with gpu options
docker run --gpus all nvidia/cuda:10.0-base nvidia-smi


# Dashboard =============================================================
Kubernetes Dashboard : https://192.168.1.248:31443/

# Monitoring =============================================================
Grafana: http://192.168.1.248:30200/     admin user: admin     admin password: deepops
Prometheus: http://192.168.1.248:30500/
Alertmanager: http://192.168.1.248:30400/

# Kubeflow =============================================================
Kubeflow app installed to: /home/vtssogari/deepops/scripts/k8s/../../config/kubeflow-install

It may take several minutes for all services to start. Run 'kubectl get pods -n kubeflow' to verify
To remove (excluding CRDs, istio, auth, and cert-manager), run: ./scripts/k8s/deploy_kubeflow.sh -d
To perform a full uninstall : ./scripts/k8s/deploy_kubeflow.sh -D
Kubeflow Dashboard (HTTP NodePort): http://192.168.1.248:31380


# offline install following tools before it run script
vim playbooks/airgap/build-offline-cache.yml

  - name: install necessary system packages
    package:
      name: "{{ item }}"
      state: present
    with_items:
    - "git"
    - "yum-utils"
    - "python3-pip"
    - "bzip2"
    ignore_errors: yes # <---- Add this then manually install following tools

sudo yum install -y git yum-utils python3-pip bzip2
pip install docker-py


vim roles/offline-repo-mirrors/defaults/main.yml
# Configure download of yum repos
centos_iso_mirror: "https://mirrors.tripadvisor.com/centos-vault/7.7.1908/isos/x86_64"
centos_iso: "CentOS-7-x86_64-Minimal-1908.iso"

# start downloading offline stuff




# Offline using Nexus Repo

-- Docker ---
Run a Registry as a pull-through cache
specify proxy.remoteurl within /etc/docker/registry/config.yml as described in the following subsection.

To configure a Registry to run as a pull through cache, the addition of a proxy section is required to the config file.

To access private images on the Docker Hub, a username and password can be supplied.

proxy:
  remoteurl: https://registry-1.docker.io
  username: [username]
  password: [password]

Configure the Docker daemon
Either pass the --registry-mirror option when starting dockerd manually, or edit /etc/docker/daemon.json 
and add the registry-mirrors key and value, to make the change persistent.

sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["http://nexus:8181"]
}
EOF

sudo systemctl daemon-reload && sudo systemctl restart docker

-- Yum --

Configuring Yum Client
Create a nexus.repo file in /etc/yum.repos.d/

[nexusrepo]
name=Nexus Repository
baseurl=http://<serveraddress:port>/repository/yum-proxy/$releasever/os/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
repo_gpgcheck=0
priority=1


-- Helm -- 
helm repo add <helm_repository_name> http://<host>:<port>/repository/<nexus_repository_name>/ --username <username> --password <password>

-- PyPi -- 

create and configure a .pypirc
[global]
index = http://localhost:8081/repository/pypi-all/pypi
index-url = http://localhost:8081/repository/pypi-all/simple

[easy_install]
index-url = http://localhost:8081/repository/pypi-proxy/simple








# Packaging Nexus for installation ==========================

# commit the changes 
docker commit nexus nexus_cached 
# save the image to tar 
docker save -o nexus_cached.tar nexus_cached

# re-running the nexus cached server
docker run -d --name nexus --net=host -e INSTALL4J_ADD_VM_PARAMS="-Xms2g -Xmx2g -XX:MaxDirectMemorySize=3g " \
nexus_cached



# Web Proxy Method ============================================

sudo yum install -y squid

vim /etc/squid/squid.conf
cache_dir ufs /var/spool/squid 500000 16 256

sudo systemctl start squid

-- yum --
vim /etc/yum.conf
proxy=http://nexus:3128 
