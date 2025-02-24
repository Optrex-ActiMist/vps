#!/bin/bash

# 下载最新版本的 Docker Compose
echo "正在下载 Docker Compose..."
wget -O /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"

# 检查下载是否成功
if [ $? -ne 0 ]; then
    echo "下载失败，请检查网络连接或 GitHub 是否可访问"
    exit 1
fi

# 赋予执行权限
echo "设置执行权限..."
chmod +x /usr/local/bin/docker-compose

# 验证安装
echo "验证安装..."
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose --version
    echo "Docker Compose 安装成功！"
else
    echo "安装失败，请检查是否已正确下载并设置权限"
    exit 1
fi
