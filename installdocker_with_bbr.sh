#!/bin/bash

set -e  # 任何错误立即退出

# 提示用户确认域名是否已解析到 VPS 的 IP 地址
echo "请问您是否已经将域名解析至 VPS 的 IP 地址？"
echo "请输入 'y' 确认，或者其他键退出："
read answer
if [ "$answer" != "y" ]; then
    echo "脚本已退出，请先解析域名后再运行。"
    exit 1
fi

# 1️⃣ 清理旧版本
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# 更新 apt 索引并安装依赖
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release
    
# 添加 Docker 的官方 GPG 密钥
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg \
 | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
配置 Docker APT 源（会自动匹配你的发行版）
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 再次更新包列表
sudo apt-get update

# 安装 Docker Engine + 官方插件（包括 compose） 
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# 启动并设置开机自启
sudo systemctl enable --now docker

验证安装
docker --version
docker compose version

echo "安装完成！docker 和 docker compose。"
