#!/bin/bash

# 提示用户确认域名是否已解析到 VPS 的 IP 地址
echo "请问您是否已经将域名解析至 VPS 的 IP 地址？"
echo "请输入 'y' 确认，或者其他键退出："
read answer
if [ "$answer" != "y" ]; then
    echo "脚本已退出，请先解析域名后再运行。"
    exit 1
fi

# 更新系统包列表
sudo apt-get update

# 安装必要的依赖
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings

# 添加 Docker 的官方 GPG 密钥
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 添加 Docker 仓库到 Apt 来源
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 再次更新包列表
sudo apt-get update

# 安装 Docker 相关组件
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 配置 BBR+CAKE
## 更新软件包列表并安装 iproute2
sudo apt update
sudo apt install iproute2 -y

## 将 CAKE 和 BBR 配置写入 sysctl.conf
echo "net.core.default_qdisc=cake" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf

## 应用配置
sudo sysctl -p


echo "安装完成！Docker 和 BBR+CAKE 已配置。"
