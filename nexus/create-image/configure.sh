#!/bin/bash
# Set the environment variables to your server eg: BASE_URL, and PASSWORD
set -x
BASE_URL=http://localhost:8081
GROOVY_SCRIPT=/tmp/docker-script.json
SCRIPT_NAME=dockerRepositories
USER=admin
DEFAULT_PASSWORD=admin123 # do not change - required for boot up
PASSWORD=password123 # set this password to what you want it to be

# write out the Groovy script for configuring the Nexus repository manager
# note the \n's are required for JSON payloads
cat <<EOF > ${GROOVY_SCRIPT}
{
"name": "${SCRIPT_NAME}",
"content": "import groovy.json.JsonOutput\n
import org.sonatype.nexus.security.realm.RealmManager\n
import org.sonatype.nexus.blobstore.api.BlobStoreManager\n
def user = security.securitySystem.getUser('admin')\n
user.setEmailAddress('admin@example.com')\n
security.securitySystem.updateUser(user)\n
security.securitySystem.changePassword('admin','${PASSWORD}')\n
log.info('default password for admin changed')\n
\n
//enable Docker Bearer Token\n
realmManager = container.lookup(RealmManager.class.name)\n
realmManager.enableRealm('DockerToken')\n
\n
//Enable anonymois access which we above disabled\n
security.anonymousAccess = true\n
security.setAnonymousAccess(true)\n
// create hosted repo and expose via https to allow deployments\n
repository.createDockerHosted('docker-internal', null, null)\n
\n
// create proxy repo of Docker Hub and enable v1 to get search to work\n
// no ports since access is only indirectly via group\n
repository.createDockerProxy('docker-hub',                   // name\n
                            'https://registry-1.docker.io', // remoteUrl\n
                            'HUB',                          // indexType\n
                            null,                           // indexUrl\n
                            null,                           // httpPort\n
                            null,                           // httpsPort\n
                            BlobStoreManager.DEFAULT_BLOBSTORE_NAME, // blobStoreName\n
                            true, // strictContentTypeValidation\n
                            true)\n
\n
// create group and allow access via https\n
def groupMembers = ['docker-hub', 'docker-internal']\n
repository.createDockerGroup('docker-all', 8181, null, groupMembers, true, BlobStoreManager.DEFAULT_BLOBSTORE_NAME, false)\n
log.info('Script dockerRepositories completed successfully')\n
",
"type": "groovy"
}
EOF

# upload the Groovy script
curl -v -u ${USER}:${DEFAULT_PASSWORD} -X POST --header 'Content-Type: application/json' \
"${BASE_URL}/service/rest/v1/script" \
-d @${GROOVY_SCRIPT}

# run the Groovy script
curl -v -X POST -u ${USER}:${DEFAULT_PASSWORD} --header "Content-Type: text/plain" "${BASE_URL}/service/rest/v1/script/${SCRIPT_NAME}/run"
