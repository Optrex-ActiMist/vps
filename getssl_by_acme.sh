#!/bin/bash

# 检查是否安装了 curl
if ! command -v curl &> /dev/null; then
    echo "系统没有发现 curl 命令，是否立刻安装 curl？（输入 Y 确认，N 退出）"
    read -r answer
    if [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
        sudo apt-get update
        sudo apt-get install -y curl
        echo "curl 已安装，继续执行后续命令..."
    else
        echo "用户选择不安装 curl，脚本退出。"
        exit 1
    fi
else
    echo "curl 已安装，继续执行..."
fi

# 执行安装 acme.sh
curl https://get.acme.sh | sh

# 刷新环境变量
source ~/.bashrc

# 安装 socat
sudo apt-get update && sudo apt-get install -y socat

# 设置默认 CA 为 Let's Encrypt
acme.sh --set-default-ca --server letsencrypt

# 提示用户输入域名并执行证书申请
echo "请输入已解析的域名（例如 example.com）："
read -r domain
if [ -z "$domain" ]; then
    echo "域名不能为空，脚本退出。"
    exit 1
else
    echo "正在为域名 $domain 申请证书..."
    acme.sh --issue -d "$domain" --standalone
    echo "脚本执行完成！请检查证书是否成功生成。"
fi
