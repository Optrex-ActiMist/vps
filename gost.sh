#!/bin/bash

# 询问用户是否开始使用 Docker 安装 Gost
echo "请问您是否开始使用 Docker 安装 Gost？"
echo "请输入 'y' 确认，或者其他键退出："
read answer
if [ "$answer" != "y" ]; then
    echo "脚本已退出。"
    exit 1
fi

# 提示用户输入变量
echo "请输入您的域名（例如 example.com）："
read DOMAIN
echo "请输入用户名："
read USER
echo "请输入密码："
read PASS
echo "请输入端口号（例如 443）："
read PORT

# 定义其他固定变量
BIND_IP=0.0.0.0
CERT_DIR=/etc/letsencrypt
CERT=${CERT_DIR}/live/${DOMAIN}/fullchain.pem
KEY=${CERT_DIR}/live/${DOMAIN}/privkey.pem

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
sudo docker run -d --name gost \\
    -v \${CERT_DIR}:\${CERT_DIR}:ro \\
    --net=host ginuerzh/gost \\
    -L "http2://\${USER}:\${PASS}@\${BIND_IP}:\${PORT}?cert=\${CERT}&key=\${KEY}&probe_resist=file:/var/www/html/index.html&knock=www.google.com"
EOF

# 给 mygost.sh 添加执行权限并运行
chmod +x mygost.sh
bash mygost.sh

# 配置 crontab
echo "配置 crontab 定时任务..."
echo "0 0 1 * * /usr/bin/certbot renew --force-renewal" | crontab -l -u root | cat - > /tmp/crontab.tmp
echo "5 0 1 * * /usr/bin/docker restart gost" | cat /tmp/crontab.tmp - > /tmp/crontab.new
crontab /tmp/crontab.new
rm /tmp/crontab.tmp /tmp/crontab.new

echo "安装完成！Gost 已启动，定时任务已配置。"
