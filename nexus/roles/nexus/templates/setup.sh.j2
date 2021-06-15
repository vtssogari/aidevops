#!/bin/bash

TAG=3.28.1
DATA=/data/nexus-data

sudo rm -rf ${DATA}

docker stop --time=120 nexus || true
docker rm -f nexus|| true

sudo mkdir -p ${DATA}/etc

# write out a Nexus configuration that will allow automated setup to run
sudo cat <<EOF | sudo tee ${DATA}/etc/nexus.properties
# Jetty section
# application-port=8081
# application-host=0.0.0.0
# nexus-args=\${jetty.etc}/jetty.xml,\${jetty.etc}/jetty-http.xml,\${jetty.etc}/jetty-requestlog.xml
# nexus-context-path=/\${NEXUS_CONTEXT}

# Nexus section
# nexus-edition=nexus-pro-edition
# nexus-features=\
#  nexus-pro-feature
# nexus.clustered=false

# activate scripting
nexus.scripts.allowCreation=true

# disable the wizard.
nexus.onboarding.enabled=false

# disable generating a random password for the admin user.
# default is: admin123
nexus.security.randompassword=false

EOF
# set permissions to that expected by the container
sudo chown -R 200 ${DATA}

# launch the Nexus service
docker run -d --name nexus \
-v ${DATA}:/nexus-data \
--net=host \
-e INSTALL4J_ADD_VM_PARAMS="-Xms2g -Xmx2g -XX:MaxDirectMemorySize=3g " \
sonatype/nexus3:${TAG}
