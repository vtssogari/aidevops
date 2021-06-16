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

##

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


# Disable Subscription Manager and install docker 
```
sudo subscription-manager config --rhsm.manage_repos=0
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker 
sudo systemctl enable docker 
```



eyJhbGciOiJSUzI1NiIsImtpZCI6IkNHRnlacmpmWVI3RnozanNjU05kQXFDRUd1QUZnd28waS03czdpSDU2UGsifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLWY4am1rIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIzNTVmZGRkMC02MDU1LTQ0MGYtOTRhOS1hY2IxYTE1YmQ5MDEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.EinrgN6jG95WW15CV3cOvvRCWvK_l1fu9OQaOMNR7yDU-l9v-_5Eeedrw4fIaLRdbUpwyQUP2-NvCOfjLarwVO2qSXdEHfJQXuTF5fVrRKHhafSj3YoalOcM2IJlrZ2pid_gh2td2Y9Wo2bpwO6a9R6EjQOE8g9WJYeFZ0H75xFPwX-QSVGsUNhes_sNgkql-c55U93d8aDPV2rfpUrWQr_hHfk4fBubuz9B8yfNYYGOeC1W6rp4P0j6dn_6Bbt_LhxJepX0Mxj9E5jFO9aSOsoWwmX2k9PCTHVQpd3PQIgc98bsGE4tbEqwpXD92vRkwq9Cp02xFH4b5t6lMnJCag
