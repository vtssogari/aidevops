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
REPOSITORY                                                                      TAG                                        IMAGE ID            CREATED             SIZE
python                                                                          3.7                                        5368dae25712        35 hours ago        877MB
mpioperator/mpi-operator                                                        latest                                     cc4ca76c8279        2 days ago          60.5MB
istio/proxyv2                                                                   1.9.5                                      89aff37ea4a7        6 weeks ago         276MB
istio/pilot                                                                     1.9.5                                      7d14cde31564        6 weeks ago         213MB
gcr.io/ml-pipeline/metadata-envoy                                               1.5.0                                      946551813998        2 months ago        245MB
gcr.io/ml-pipeline/cache-deployer                                               1.5.0                                      31c6b8a1eada        2 months ago        1.73GB
gcr.io/ml-pipeline/scheduledworkflow                                            1.5.0                                      fe8bdc918213        2 months ago        110MB
public.ecr.aws/j1r0q0g6/notebooks/volumes-web-app                               v1.3.0-rc.1                                89a72e9937f4        2 months ago        164MB
public.ecr.aws/j1r0q0g6/notebooks/jupyter-web-app                               v1.3.0-rc.1                                c6b869180bd0        2 months ago        164MB
public.ecr.aws/j1r0q0g6/notebooks/tensorboards-web-app                          v1.3.0-rc.1                                12c7cca2cb13        2 months ago        163MB
public.ecr.aws/j1r0q0g6/notebooks/central-dashboard                             v1.3.0-rc.1                                dc6f115a691d        2 months ago        203MB
public.ecr.aws/j1r0q0g6/notebooks/access-management                             v1.3.0-rc.1                                7727002de274        2 months ago        64MB
public.ecr.aws/j1r0q0g6/notebooks/notebook-controller                           v1.3.0-rc.1                                c61c9f542d8c        2 months ago        58.3MB
quay.io/jetstack/cert-manager-cainjector                                        v1.3.1                                     394d99f56897        2 months ago        47.7MB
quay.io/jetstack/cert-manager-controller                                        v1.3.1                                     7ad279b7cce9        2 months ago        64MB
quay.io/jetstack/cert-manager-webhook                                           v1.3.1                                     a4c219b364a0        2 months ago        50.1MB
k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner                          v4.0.2                                     932b0bface75        2 months ago        43.8MB
kubeflow/mxnet-operator                                                         v1.1.0                                     9863e44e3a08        3 months ago        971MB
kubeflowkatib/katib-ui                                                          v0.11.0                                    aaf8228a161f        3 months ago        82.2MB
kubeflowkatib/katib-db-manager                                                  v0.11.0                                    f54bf79113dc        3 months ago        27.4MB
public.ecr.aws/j1r0q0g6/training/tf-operator                                    cd2fc1ff397b1f349f68524f4abd5013a32e3033   b54e1718135c        3 months ago        65.7MB
k8s.gcr.io/pause                                                                3.4.1                                      0f8457a4c2ec        5 months ago        683kB
gcr.io/tfx-oss-public/ml_metadata_store_server                                  0.25.1                                     66134141c949        6 months ago        76.5MB
gcr.io/knative-releases/knative.dev/eventing/cmd/in_memory/channel_controller   <none>                                     381aad829838        7 months ago        63.7MB
gcr.io/knative-releases/knative.dev/eventing/cmd/controller                     <none>                                     7f61334a0d64        7 months ago        66.9MB
gcr.io/knative-releases/knative.dev/eventing/cmd/mtbroker/ingress               <none>                                     46dea7cae0ef        7 months ago        63.6MB
gcr.io/knative-releases/knative.dev/eventing/cmd/webhook                        <none>                                     ae423bb94d06        7 months ago        65MB
gcr.io/knative-releases/knative.dev/eventing/cmd/mtchannel_broker               <none>                                     6e319d576a4f        7 months ago        63.4MB
gcr.io/knative-releases/knative.dev/eventing/cmd/mtbroker/filter                <none>                                     f427a9b9f30e        7 months ago        63.6MB
gcr.io/knative-releases/knative.dev/eventing/cmd/in_memory/channel_dispatcher   <none>                                     690e3e3d1af0        7 months ago        64.7MB
gcr.io/knative-releases/knative.dev/serving/cmd/webhook                         <none>                                     c24639c44057        8 months ago        64MB
gcr.io/knative-releases/knative.dev/serving/cmd/controller                      <none>                                     59a625af711a        8 months ago        69MB
gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler                      <none>                                     c97f24221fda        8 months ago        63.8MB
gcr.io/knative-releases/knative.dev/serving/cmd/activator                       <none>                                     e1f3cb67a23e        8 months ago        63.6MB
gcr.io/knative-releases/knative.dev/net-istio/cmd/controller                    <none>                                     adcff15bf30f        9 months ago        66MB
gcr.io/knative-releases/knative.dev/net-istio/cmd/webhook                       <none>                                     2850f040eaf2        9 months ago        60MB
quay.io/dexidp/dex                                                              v2.24.0                                    bb0b95a82a8a        13 months ago       34.2MB
metacontroller/metacontroller                                                   v0.3.0                                     5f0e4bc196e2        2 years ago         97.5MB

```
# Disable Subscription Manager and install docker 
```
sudo subscription-manager config --rhsm.manage_repos=0
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker 
sudo systemctl enable docker 
```

# install online kubenernetes and kubeflow 

```

sudo yum install -y kubeadm kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

sudo swapoff -a 
# remove swap
sudo vi /etc/fstab

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
sudo rm -f /var/lib/etcd

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml



# install NFS server

sudo yum install -y nfs-utils rpcbind
sudo systemctl enable nfs-server
sudo systemctl enable rpcbind
sudo systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
sudo systemctl status nfs
sudo mkdir /data
sudo chmod 1777 /data

# edit here ####

sudo vim /etc/exports

/data *(rw)


sudo exportfs -r
sudo systemctl restart nfs-server

# install nfs provisioner
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/

# get IP 
ip add

# replace ip
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=192.168.56.108 --set nfs.path=/data
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# install Kubeflow

wget https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64
chmod +x kustomize_3.2.0_linux_amd64
sudo cp kustomize_3.2.0_linux_amd64 /usr/local/bin/kustomize
rm kustomize_3.2.0_linux_amd64 

sudo yum install -y git 
git clone https://github.com/kubeflow/manifests.git
cd manifests/
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done



```

# importing all images to offline server

from virtualbox
```
docker images --format "{{.Repository}} {{.Tag}} {{.ID}}" | tr -c "a-z A-Z0-9_.\n-" "%" | while read REPOSITORY TAG IMAGE_ID
do
  echo "== Saving $REPOSITORY $TAG $IMAGE_ID =="
  docker  save   -o /path/to/save/$REPOSITORY-$TAG-$IMAGE_ID.tar $IMAGE_ID
done
docker images --format "{{.Repository}} {{.Tag}} {{.ID}}" > mydockersimages.list
```

In offline server
```
ls -1 *.tar | xargs --no-run-if-empty -L 1 docker load -i

```
