#!/bin/bash

# 提示用户确认域名是否已解析到 VPS 的 IP 地址
echo "请问您是否已经将域名解析至 VPS 的 IP 地址？"
echo "请输入 'y' 确认，或者其他键退出："
read answer
if [ "$answer" != "y" ]; then
    echo "脚本已退出，请先解析域名后再运行。"
    exit 1
fi

# 更新 apt 软件包列表
sudo apt update

# 安装 snapd
sudo apt install -y snapd

# 安装 core (snapd 的核心组件)
sudo snap install core

# 再次更新 apt 软件包列表 (snapd 安装后可能需要)
sudo apt-get update

# 安装 certbot (现在官方推荐通过 snap 安装 Certbot，而不是通过 apt)
sudo snap install --classic certbot

# 允许 80 端口 (HTTP)
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT

# 允许 443 端口 (HTTPS)
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT

# 保存 iptables 规则（确保重启后规则仍然生效）
sudo apt install -y iptables-persistent
sudo netfilter-persistent save

# 运行 certbot (standalone 模式)
sudo certbot certonly --standalone

echo "Certbot 安装完成！请按照 certbot 的提示完成证书申请。"
