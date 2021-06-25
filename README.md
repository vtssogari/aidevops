# AI Devops
AI Platform Installation Automation 

## Nexus Server Setup
Scripts will prepare nexus offline for Kubenetes installations
```
./nexus/scripts/setup.sh

ansible-playbook -i inventory playbook-nexus-update.yml # creates new configure.sh 
./nexus/scripts/configure.sh [password here]
```
## Nexus offline Server Setup

- create the tar /data folder
```
tar -cvzf nexus_data.tgz /data 
```
- from offline server run following 
```
./nexus/scripts/setup.sh
tar -xvzf nexus_data.tgz 
```
### Prepare kubernetes nodes for offline installation

* update group_vars for nexus ip address first 
* then run these scripts from ansible master

```
ansible-playbook -i inventory playbook-bootstrap.yml
ansible-playbook -i inventory playbook-yum.yml
ansible-playbook -i inventory playbook-docker.yml
ansible-playbook -i inventory playbook-pypi.yml
ansible-playbook -i inventory playbook-static-file.yml
```

## Installing kubeadm, kubectl

```
sudo yum install -y kubeadm kubectl
```

## Deploying Kubernetes cluster 

```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```
* If error, "cannot use "0.0.0.0" as the bind address for the API Server", then 
*  add default gate way - flannel is failing because of the default gateway is not defined

```
sudo ip route add default via 192.168.56.1
```

### Create a file named /etc/sysconfig/network-scripts/route-eth0
```

```

### kubectl client enable 
```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## flannel network install 

```
kubectl apply -f http://nexus:8081/repository/http-hosted/coreos/flannel/master/Documentation/kube-flannel.yml
```

## nginx controller

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/baremetal/deploy.yaml

kubectl apply -f http://nexus:8081/repository/http-hosted/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/baremetal/deploy.yaml

```

## Dash board 

```
wget http://nexus:8081/repository/http-hosted/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
```
* change the manifest file "recommended.yaml" imagePullPolicy from Always to IfNotPresent, then
```
kubectl apply -f http://nexus:8081/repository/http-hosted/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

kubectl apply -f http://192.168.56.109:8081/repository/http-hosted/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

```
## Enable admin service account 
```
kubectl apply -f dashboard-adminuser.yaml
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```
## enable Ingress controller or NodePort service for dashboard
```
kind: ServiceapiVersion: v1
metadata:
  name: kubernetes-dashboard-nodeport
  namespace: kubernetes-dashboard
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30002
  selector:
    k8s-app: kubernetes-dashboard
```
## test the stateless web application 

## Setup the NFS storage class 

## test the stateful application setup

## deploy ELK application 

## deploy kubeflow

1. get kustomize and install
```
wget https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64
chmod +x kustomize_3.2.0_linux_amd64
sudo cp kustomize_3.2.0_linux_amd64 /usr/local/bin/kustomize
```

2. clone kubeflow manifest 
```
git clone https://github.com/kubeflow/manifests.git
cd manifests

```
3. change the default password for dex

```
pip3 install passlib bcrypt
python3 -c 'from passlib.hash import bcrypt; import getpass; print(bcrypt.using(rounds=12, ident="2y").hash(getpass.getpass()))'
```
4. Edit dex/base/config-map.yaml and fill the relevant field with the hash of the password you chose:
```
...
  staticPasswords:
  - email: user@example.com
    hash: <enter the generated hash here>
```
5. Install Kubeflow components

```
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

```

##
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.1.193

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:
```

# All the docker images for Kubernetes 1.21
```
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-apiserver            v1.21.2             106ff58d4308        8 days ago          126MB
k8s.gcr.io/kube-proxy                v1.21.2             a6ebd1c1ad98        8 days ago          131MB
k8s.gcr.io/kube-controller-manager   v1.21.2             ae24db9aa2cc        8 days ago          120MB
k8s.gcr.io/kube-scheduler            v1.21.2             f917b8c8f55b        8 days ago          50.6MB
kubernetesui/dashboard               v2.3.1              e1482a24335a        8 days ago          220MB
quay.io/coreos/flannel               v0.14.0             8522d622299c        5 weeks ago         67.9MB
k8s.gcr.io/pause                     3.4.1               0f8457a4c2ec        5 months ago        683kB
k8s.gcr.io/coredns/coredns           v1.8.0              296a6d5035e2        8 months ago        42.5MB
kubernetesui/metrics-scraper         v1.0.6              48d79e554db6        8 months ago        34.5MB
k8s.gcr.io/etcd                      3.4.13-0            0369cf4303ff        10 months ago       253MB
quay.io/coreos/etcd                  v3.4.3              a0b920cf970d        20 months ago       83.6MB

```
# All the docker images for Kubeflow 
```

```
# Disable Subscription Manager and install docker 
```
sudo subscription-manager config --rhsm.manage_repos=0
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker 
sudo systemctl enable docker 
```
