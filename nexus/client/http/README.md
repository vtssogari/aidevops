# setup RAW repository 



curl -v --user 'admin:password123' --upload-file ./test.png http://nexus:8081/repository/http-hosted/


List 

# Misc download urls
docker_compose_url: "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-Linux-x86_64"
ksonnet_url: "https://github.com/ksonnet/ksonnet/releases/download/v0.13.1/ks_0.13.1_linux_amd64.tar.gz"
kubectl_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/amd64/kubectl"
kubeadm_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/amd64/kubeadm"
hyperkube_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/amd64/hyperkube"
nvidia_k8s_device_plugin_url: "https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/1.0.0-beta4/nvidia-device-plugin.yml"
nvidia_docker_wrapper_url: "https://raw.githubusercontent.com/NVIDIA/nvidia-docker/master/nvidia-docker"
cni_download_url: "https://github.com/containernetworking/plugins/releases/download/{{ cni_version }}/cni-plugins-linux-amd64-{{ cni_version }}.tgz"

