#!/bin/bash
TAG=3.28.1
DATA=nexus_data.tar

cd /
tar -xvzf nexus_data.tar 
docker stop --time=120 nexus || true
docker rm -vf nexus|| true
# launch the Nexus service
docker run -d --name nexus --network=host -e INSTALL4J_ADD_VM_PARAMS="-Xms2g -Xmx2g -XX:MaxDirectMemorySize=3g " sonatype/nexus3:${TAG}

sleep 120
./configure.sh