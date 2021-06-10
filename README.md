# AI Devops
AI Platform Installation Automation 

Scripts will prepare nexus offline for Kubenetes installations

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
DOCKERCONFIG

REPOSITORY                                         TAG       

- "nginx:1.19"
- "registry:2.7"
- "lachlanevenson/k8s-helm:v3.4.1"
- "k8s.gcr.io/kube-proxy:v1.18.9"
- "k8s.gcr.io/kube-controller-manager:v1.18.9"
- "k8s.gcr.io/kube-apiserver:v1.18.9"
- "k8s.gcr.io/kube-scheduler:v1.18.9"
- "calico/node:v3.15.2"
- "calico/cni:v3.15.2"
- "calico/kube-controllers:v3.15.2"
- "kubernetesui/dashboard:v2.0.3"
- "k8s.gcr.io/cluster-proportional-autoscaler-amd64:1.8.1"
- "kubernetesui/metrics-scraper:v1.0.5"
- "quay.io/kubernetes_incubator/node-feature-discovery:v0.6.0"
- "k8s.gcr.io/k8s-dns-node-cache:1.15.13"
- "k8s.gcr.io/pause:3.2"
- "coredns/coredns:1.6.7"
- "quay.io/coreos/etcd:v3.4.3"
- "quay.io/external_storage/nfs-client-provisioner:v3.1.0-k8s1.11"


sudo docker rmi f0b8a9a54136 1fd8e1b0bb7e 6648ad019b78 10ffdd81fbb3 dacf3f247065 e9585e7d0849 c53af2e3d068 cc7508d4d2d4 5dadc388f979 fbbc4a1a0e98 503bc4b7440b 17ffd2ee7ad8 2cd72547f23f b7f4ca5c9efc 3f7a09f7cade 80d28bedfe5d 67da37a9a360 a0b920cf970d 16d2f904b0d8