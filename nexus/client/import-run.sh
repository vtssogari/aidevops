docker load -i nexus_cached.tar
docker run -d --name nexus --restart unless-stopped --network=host nexus_cached