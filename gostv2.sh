#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# 询问用户是否开始使用 Docker 安装 Gost
echo "请问您是否开始使用 Docker 安装 Gost？"
echo "请输入 'y' 确认，或者其他键退出："
read answer
if [ "$answer" != "y" ]; then
    echo "脚本已退出。"
    exit 1
fi

# 打开443 端口
ufw allow 443

# 提示用户输入变量
echo "请输入您的域名（例如 example.com）："
read DOMAIN
echo "请输入用户名："
read USER
echo "请输入密码："
read PASS
echo
echo "请输入端口号（例如 443）："
read PORT

# Validate port number
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "错误：端口号必须是 1-65535 之间的数字。"
    exit 1
fi

# 定义其他固定变量
BIND_IP=0.0.0.0
CERT_DIR=/etc/letsencrypt
CERT=${CERT_DIR}/live/${DOMAIN}/fullchain.pem
KEY=${CERT_DIR}/live/${DOMAIN}/privkey.pem

# Check if certificate exists
if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
    echo "警告：证书文件不存在。请确保已经为 $DOMAIN 申请了 Let's Encrypt 证书。"
    echo "是否继续？(y/n)"
    read continue_answer
    if [ "$continue_answer" != "y" ]; then
        echo "脚本已退出。"
        exit 1
    fi
fi

# 创建 mygost.sh 文件
cat << EOF > mygost.sh
#!/bin/bash

DOMAIN="$DOMAIN"
USER="$USER"
PASS="$PASS"
PORT=$PORT

BIND_IP=0.0.0.0
CERT_DIR=/etc/letsencrypt
CERT=\${CERT_DIR}/live/\${DOMAIN}/fullchain.pem
KEY=\${CERT_DIR}/live/\${DOMAIN}/privkey.pem
sudo docker run -d --name gost \
    --restart unless-stopped \
    -v \${CERT_DIR}:\${CERT_DIR}:ro \
    --net=host \
    --log-opt max-size=10m \
    --log-opt max-file=3 \
    gogost/gost:latest \
-L "http+mtls://${USER}:${PASS}@${BIND_IP}:8443?cert=${CERT}&key=${KEY}&probe_resist=file:/var/www/html/index.html&knock=www.google.com&minVersion=VersionTLS13&muxKeepAliveInterval=6&muxKeepAliveTimeout=3s&muxConcurrency=64&muxMaxFrameSize=65536&muxMaxReceiveBuffer=8388608&muxMaxStreamBuffer=131072&nodelay=true&tls_session_ticket=true" 
EOF

# 给 mygost.sh 添加执行权限并运行
chmod +x mygost.sh
bash mygost.sh

echo "安装完成！Gost 已启动。"
echo "您可以使用以下命令查看日志："
echo "docker logs gost"
