#!/bin/bash

# 更新 apt 软件包列表
sudo apt update

# 安装 snapd
sudo apt install snapd

# 安装 core (snapd 的核心组件)
sudo snap install core

# 再次更新 apt 软件包列表 (snapd 安装后可能需要)
sudo apt-get update

# 安装 certbot
sudo apt-get install certbot

# 安装 certbot 的 nginx 插件
apt install -y python3-certbot-nginx

# 允许 80 端口 (HTTP)
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT

# 允许 443 端口 (HTTPS)
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT

# 运行 certbot (standalone 模式)
sudo certbot certonly --standalone

echo "Certbot 安装完成！请按照 certbot 的提示完成证书申请。"
