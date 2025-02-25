#!/bin/bash

# Set up directory for Nginx Proxy Manager
mkdir -p ~/nginx-proxy-manager
cd ~/nginx-proxy-manager

# Create docker-compose.yml file
cat << EOF > docker-compose.yml
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80' # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '81:81' # Admin Web Port
      # - '21:21' # FTP
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

# Create data directories
mkdir -p data letsencrypt

# Deploy Nginx Proxy Manager
docker compose up -d

echo "Nginx Proxy Manager deployed! Access it at http://<your-vps-ip>:81"
echo "Default login: admin@example.com / changeme (change it on first login)"
