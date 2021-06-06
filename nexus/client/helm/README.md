# Nexus Helm Proxy setting 

create multiple repos 

Define URL for Remote storage : 

ex)
	Name			URL
    helm-google		https://kubernetes-charts.storage.googleapis.com
	helm-stable          	https://charts.helm.sh/stable
	helm-mumoshu         	https://mumoshu.github.io/charts
	...

# add helm repos from command line

helm repo add kubernetes http://nexus:8081/repository/helm-google
helm repo add stable http://nexus:8081/repository/helm-stable
helm repo add mumoshu http://nexus:8081/repository/helm-mumoshu

# searching 

helm search repo stable

helm repo update
helm install stable/airflow --generate-name 
