#!/bin/bash

# 更新包索引（仅执行一次）
sudo apt update -y

# 检查并安装 curl
if ! type curl >/dev/null 2>&1; then
    echo "未找到 curl，是否安装？（输入 Y 确认，N 退出）"
    read -r answer
    if [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
        sudo apt install -y curl || { echo "安装 curl 失败，脚本退出"; exit 1; }
        echo "curl 已安装，继续执行..."
    else
        echo "用户选择不安装 curl，脚本退出。"
        exit 1
    fi
else
    echo "curl 已安装，继续执行..."
fi

# 安装 acme.sh 并检查是否成功
echo "正在安装 acme.sh..."
curl https://get.acme.sh | sh || { echo "acme.sh 安装失败，脚本退出"; exit 1; }
echo "acme.sh 安装完成。"

# 动态获取 acme.sh 路径（默认安装在 ~/.acme.sh）
ACME_PATH="$HOME/.acme.sh/acme.sh"
if [ ! -f "$ACME_PATH" ]; then
    echo "未找到 acme.sh 可执行文件，请检查安装是否正确，脚本退出。"
    exit 1
fi

# 设置默认 CA 为 ZeroSSL
"$ACME_PATH" --set-default-ca --server zerossl || { echo "设置 ZeroSSL 为默认 CA 失败，脚本退出"; exit 1; }
echo "已将 ZeroSSL 设置为默认证书颁发机构。"

# 检查是否已注册 ZeroSSL 账户，若未注册则提示输入邮箱
if ! "$ACME_PATH" --list | grep -q "zerossl"; then
    echo "ZeroSSL 需要注册账户，请输入您的邮箱地址（例如 my@example.com）："
    read -r email
    if [ -z "$email" ] || ! echo "$email" | grep -qE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'; then
        echo "邮箱格式不合法，脚本退出。"
        exit 1
    fi
    echo "正在注册 ZeroSSL 账户..."
    "$ACME_PATH" --register-account -m "$email" || { echo "账户注册失败，请检查邮箱或网络，脚本退出"; exit 1; }
    echo "ZeroSSL 账户注册成功！"
else
    echo "ZeroSSL 账户已存在，继续执行..."
fi

# 提示用户输入域名并验证
echo "请输入已解析的域名（例如 example.com）："
read -r domain
if [ -z "$domain" ]; then
    echo "域名不能为空，脚本退出。"
    exit 1
elif ! echo "$domain" | grep -qE '^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'; then
    echo "域名格式不合法，脚本退出。"
    exit 1
else
    echo "正在为域名 $domain 申请 ZeroSSL 证书..."
    "$ACME_PATH" --issue -d "$domain" --standalone
    if [ $? -eq 0 ]; then
        echo "证书申请成功！证书路径：$HOME/.acme.sh/$domain/"
    else
        echo "证书申请失败，请检查以下内容："
        echo "1. 域名 $domain 是否正确解析到本机 IP"
        echo "2. 80 端口是否被占用"
        echo "3. 可添加 '--debug' 查看详细日志：$ACME_PATH --issue -d $domain --standalone --debug"
        exit 1
    fi
fi

echo "脚本执行完成！"
