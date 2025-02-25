mkdir ~/portainer
cd ~/portainer
docker pull portainer/portainer-ce:latest

docker run -d --name portainer --restart unless-stopped \
    -p 9000:9000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

