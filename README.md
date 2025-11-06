# 新建VPS快捷运行脚本：
### 1. 安装 docker，docker-compose 和 BBR
```
apt update
apt install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl status docker --no-pager
```
或者：
```
bash <(curl -sL 'https://get.docker.com')
```
### 2. 申请 SSL 证书，以下二选一(若安装Nginx，这一步可省略)：
##### - 安装 Cerbot 并使用 Letsencrypt standalone方式申请证书
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/getssl.sh)
```
##### - 安装 acme.sh 并使用 zerossl standalone 方式申请证书
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/getssl_byacme.sh)
```

### 3. 安装 gost (须先使用Letsencrypt申请证书) 
##### 原版：
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/gostv1.sh)
```
##### 改进版(须先使用Letsencrypt申请证书)（加上h3支持及多路复用、提高并发）：
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/gostv2.sh)
```

### 4. 安装 Nginx Proxy Manager，申请SSL证书 
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/install_NginxProxyManager.sh)
```

### 5. 安装 tugtainer （自动更新 docker image）
```
# create volume
docker volume create tugtainer_data

# pull image
docker pull quenary/tugtainer:latest

# run container
docker run -d -p 9412:80 \
    --name=tugtainer \
    --restart=unless-stopped \
    -v tugtainer_data:/tugtainer \
    -v /var/run/docker.sock:/var/run/docker.sock \
    quenary/tugtainer:latest
```
或者，安装watchtower：
```
docker run --detach \
  --name watchtower \
  --restart unless-stopped \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  -e TZ=Asia/Shanghai \
  -e WATCHTOWER_CLEANUP=true \
  -e WATCHTOWER_SCHEDULE="0 0 4 * * *" \
  -e WATCHTOWER_LABEL_ENABLE=true \
  -e WATCHTOWER_MONITORING_PERIOD=24h \
  containrrr/watchtower:latest
`````````````````````````
检查watchtower运行日志：
```
docker logs watchtower
```

### 6. 安装 vocechat (https://doc.voce.chat/)
```
# 运行容器
docker run -d \
    --restart=unless-stopped \
      -p 3001:3000 \
      --name vocechat-server \
      -v vocechat-data:/home/vocechat-server/data \
      privoce/vocechat-server:latest
``` 
上面-v 命令的作用是：把用户数据映射到 vocechat-data 卷，没有的话就新建

### 7. 安装 PDF MathTranslate [https://github.com/Byaidu/PDFMathTranslate]
```
docker pull byaidu/pdf2zh
docker run -d --restart unless-stopped -p 7860:7860 byaidu/pdf2zh
```
### 8. 优化 vps 虚拟内存
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/swap.sh)
```
### 9. Prompt Optimizer 
```
docker run -d -p 8081:80 --restart unless-stopped --name prompt-optimizer linshen/prompt-optimizer
```
### 10. SearXNG
```
mkdir my-instance
cd my-instance
export PORT=8088
docker pull searxng/searxng
docker run -d --restart unless-stopped \
-v "${PWD}/searxng:/etc/searxng" \
-e "BASE_URL=http://localhost:$PORT/" \
-e "INSTANCE_NAME=my-instance" \
-p $PORT:8080 \
searxng/searxng
```
  **之后在 Nginx Proxy Manager 里把 search.domain.com 反代到 8088端口即可**

### 11. deep-research-u14 
```
docker run -d \
    --restart=unless-stopped \
    -p 3333:3000 \
    --name deep-research \
    xiangfa/deep-research:latest
```

### 12. deep-research-web  [https://github.com/AnotiaWang/deep-research-web-ui]
```
docker run -d \
    --restart=unless-stopped \
    -p 3000:3000 \
    --name deep-research-web \
    anotia/deep-research-web:latest
```
### 13. Kresearch [https://github.com/KuekHaoYang/KResearch]
```
sudo apt-get update && sudo apt-get install -y qemu-user-static
sudo systemctl enable --now systemd-binfmt.service
sudo systemctl status systemd-binfmt.service
sudo systemctl enable --now binfmt-support.service
docker run --platform linux/arm64 -d --restart=unless-stopped -p 8081:80 --name kresearch kuekhaoyang/kresearch:latest
```

### 14. 订阅管理 [https://github.com/huhusmang/Subscription-Management]
**docker compose 部署**
1. Clone the project
```
git clone https://github.com/huhusmang/subscription-management.git
cd subscription-management
```
2. Configure environment variables
```
nano .env
```
3. copy 以下代码，并做相应修改：
```
# API security key (required for all protected endpoints)
API_KEY=KnjzaUtgRBiAkKoJ

# Service port (optional, default 3001)
PORT=3002

# Base currency (optional, default CNY)
# Supported: USD, EUR, GBP, CNY, JPY, CAD, AUD, TRY
BASE_CURRENCY=CNY

# Database path (used for Docker deployment)
DATABASE_PATH=/app/data/database.sqlite

# Tianapi API key (optional, for real-time exchange rate updates)
# Get your key from: https://www.tianapi.com/
TIANAPI_KEY=2d6ab562e5dbebdb480a1781b69880a0

# Telegram Bot Token (required for Telegram notifications)
# Get from @BotFather on Telegram
TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here

# notification settings
NOTIFICATION_DEFAULT_CHANNELS=["telegram"]
NOTIFICATION_DEFAULT_LANGUAGE=en
SCHEDULER_TIMEZONE=UTC
SCHEDULER_CHECK_TIME=09:00
NOTIFICATION_DEFAULT_ADVANCE_DAYS=7
NOTIFICATION_DEFAULT_REPEAT_NOTIFICATION=false
```
4. Start services：
```
docker compose up -d
```
5. 在cloudflare做二级域名，在 Nginx Proxy Manager里申请SSL
6. 默认：
用户名：admin
密码： admin

### 15. Stirling-PDF
1. 创建目录
```
mkdir ~/stirlingpdf
cd ~/stirlingpdf
```
2. 用编辑器创建 docker-compose.yml
```
nano docker-compose.yml
```
3. 粘贴以下内容到编辑器里(修改外部端口号以避免冲突)：
```
services:
  stirling-pdf:
    image: docker.stirlingpdf.com/stirlingtools/stirling-pdf:latest
    ports:
      - '8082:8080'
    volumes:
      - ./StirlingPDF/trainingData:/usr/share/tessdata # Required for extra OCR languages
      - ./StirlingPDF/extraConfigs:/configs
      - ./StirlingPDF/customFiles:/customFiles/
      - ./StirlingPDF/logs:/logs/
      - ./StirlingPDF/pipeline:/pipeline/
    environment:
      - DISABLE_ADDITIONAL_FEATURES=false
      - LANGS=en_GB
```
4. 后台启动 docker
```
docker compose up -d
```

* ### 其它 Docker 镜像：
  * WordPress
  * Markitdown
  * 雷池 WAF
  * Perplexica
  * caddy
  * ollama
  * Uptime Kuma https://github.com/louislam/uptime-kuma
  * SamWaf https://github.com/samwafgo/SamWaf

* ### 其它工具
- acme.sh (可以申请支持通配符的证书，自动续期)
- 3x-ui [https://github.com/MHSanaei/3x-ui/tree/main]
