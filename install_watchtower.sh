docker run -d --name watchtower --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e WATCHTOWER_SCHEDULE="0 0 */2 * * *" \
    containrrr/watchtower
