#!/bin/bash
# Set the environment variables to your server eg: BASE_URL, and PASSWORD
set -x
BASE_URL=http://localhost:8081
GROOVY_SCRIPT=/tmp/docker-script.json
SCRIPT_NAME=initialRepositories4
USER=admin
DEFAULT_PASSWORD=admin123 # do not change - required for boot up
PASSWORD=$1 # set this password to what you want it to be
EMAIL=admin@fda.gov 

# write out the Groovy script for configuring the Nexus repository manager
# note the \n's are required for JSON payloads
cat <<EOF > ${GROOVY_SCRIPT}
{
"name": "${SCRIPT_NAME}",
"content": "import groovy.json.JsonOutput \n
import org.sonatype.nexus.security.realm.RealmManager \n
import org.sonatype.nexus.blobstore.api.BlobStoreManager \n
def user = security.securitySystem.getUser('admin') \n
user.setEmailAddress('${EMAIL}') \n
security.securitySystem.updateUser(user) \n
security.securitySystem.changePassword('admin','${PASSWORD}') \n
log.info('default password for admin changed') \n

//enable Docker Bearer Token \n
realmManager = container.lookup(RealmManager.class.name) \n
realmManager.enableRealm('DockerToken') \n

//Enable anonymois access which we above disabled \n
security.anonymousAccess = true \n
security.setAnonymousAccess(true) \n
// create hosted repo and expose via https to allow deployments \n
repository.createDockerHosted('docker-internal', null, null) \n

// create proxy repo of Docker Hub and enable v1 to get search to work \n
// no ports since access is only indirectly via group \n
repository.createDockerProxy('docker-hub','https://registry-1.docker.io', 'HUB',null,null,null); \n

// create group and allow access via https \n
def groupMembers = ['docker-hub', 'docker-internal'] \n
repository.createDockerGroup('docker-all', 8181, null, groupMembers); \n
log.info('Script dockerRepositories completed successfully'); \n

// setup http server \n
repository.createRawHosted('http-hosted'); \n
log.info('Script http-hosted completed successfully'); \n

// setup pypi repo \n
repository.createPyPiProxy('pypi-proxy', 'https://pypi.org'); \n
repository.createPyPiGroup('python-repo', ['pypi-proxy']); \n
log.info('Script python-repo completed successfully'); \n

// setup Yum Proxy repos \n
repository.createYumProxy('yum-centos', 'http://mirror.vtti.vt.edu/centos/7.9.2009/os/x86_64/', BlobStoreManager.DEFAULT_BLOBSTORE_NAME, true); \n
repository.createYumProxy('yum-centos-extras', 'http://mirror.es.its.nyu.edu/centos/7.9.2009/extras/x86_64/', BlobStoreManager.DEFAULT_BLOBSTORE_NAME, true); \n
repository.createYumProxy('yum-centos-updates', 'http://mirror.vtti.vt.edu/centos/7.9.2009/updates/x86_64/', BlobStoreManager.DEFAULT_BLOBSTORE_NAME, true); \n
repository.createYumProxy('yum-centosplus', 'http://mirror.cs.vt.edu/pub/CentOS/7.9.2009/centosplus/x86_64/', BlobStoreManager.DEFAULT_BLOBSTORE_NAME, true); \n
repository.createYumProxy('yum-cuda', 'https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/', BlobStoreManager.DEFAULT_BLOBSTORE_NAME, true); \n
repository.createYumProxy('yum-docker-ce-stable', 'https://download.docker.com/linux/centos/7/x86_64/stable', BlobStoreManager.DEFAULT_BLOBSTORE_NAME, true); \n
repository.createYumProxy('yum-epel', 'https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/'); \n
repository.createYumProxy('yum-kubernetes', 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64'); \n
repository.createYumProxy('yum-libnvidia-container', 'https://nvidia.github.io/libnvidia-container/centos7/x86_64'); \n
repository.createYumProxy('yum-nvidia-container-runtime', 'https://nvidia.github.io/nvidia-container-runtime/centos7/x86_64'); \n
repository.createYumProxy('yum-nvidia-dgx-7', 'https://international.download.nvidia.com/dgx/repos/rhel7/'); \n
repository.createYumProxy('yum-nvidia-dgx-7-updates', 'https://international.download.nvidia.com/dgx/repos/rhel7-updates/'); \n
repository.createYumProxy('yum-nvidia-docker', 'https://nvidia.github.io/nvidia-docker/centos7/x86_64'); \n
repository.createYumProxy('yum-nvidia-ml', 'https://developer.download.nvidia.com/compute/machine-learning/repos/rhel7/x86_64/'); \n 
log.info('Script yum proxy repo completed successfully'); \n
",
"type": "groovy"
}
EOF

# upload the Groovy script
curl -v -u ${USER}:${DEFAULT_PASSWORD} -X POST --header 'Content-Type: application/json' "${BASE_URL}/service/rest/v1/script" -d @${GROOVY_SCRIPT}

# run the Groovy script
curl -v -X POST -u ${USER}:${DEFAULT_PASSWORD} --header "Content-Type: text/plain" "${BASE_URL}/service/rest/v1/script/${SCRIPT_NAME}/run"
