#!/bin/bash

docker stop --time=120 nexus || true
docker rm -vf nexus|| true
# launch the Nexus service
docker build -t nexus_cache .
docker run -d --name nexus --network=host -e INSTALL4J_ADD_VM_PARAMS="-Xms2g -Xmx2g -XX:MaxDirectMemorySize=3g " nexus_cache
sleep 120
./configure.sh