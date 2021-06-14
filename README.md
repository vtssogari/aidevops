# AI Devops
AI Platform Installation Automation 

Scripts will prepare nexus offline for Kubenetes installations

# add default gate way - flannel is failing because of the default gateway is not defined

[root@rhel7 ~]# cat /etc/sysconfig/network
GATEWAY="10.1.1.1"
[root@rhel7 ~]# systemctl restart network
[root@rhel7 ~]# routel | grep default
        default          10.1.1.1                   static          enp0s3 
        default        unreachable                   kernel              lo unspec
        default        unreachable                   kernel    



# nginx controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/baremetal/deploy.yaml

kubectl apply -f http://nexus:8081/repository/http-hosted/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/cloud/deploy.yaml



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

sudo kubeadm join 192.168.1.193:6443 --token xcf0du.mxtapu52ck85aaaw --discovery-token-ca-cert-hash sha256:1c6a9aa58b286bb483276ac893daf29c3f1ab8ab926dc02a30853189ec37bb0a


# Disable Subscription Manager 
sudo subscription-manager config --rhsm.manage_repos=0
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker 
sudo systemctl enable docker 


sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["http://192.168.1.214:8181"],
  "insecure-registries" : ["192.168.1.214:8181"]
}
