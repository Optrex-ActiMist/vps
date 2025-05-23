# 新建VPS快捷运行脚本：
### 1. 安装 docker，docker-compose 和 BBR
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/installdocker_with_bbr.sh)
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

### 5. 安装 Portainer(docker管理工具)
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/refs/heads/main/install_Portainer.sh)
```

### 6. 安装 Watchtower （自动更新 docker image）
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/install_watchtower.sh)
```

### 7. 安装 vocechat (https://doc.voce.chat/)
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

### 8. 安装 PDF MathTranslate [https://github.com/Byaidu/PDFMathTranslate]
```
docker pull byaidu/pdf2zh
docker run -d --restart unless-stopped -p 7860:7860 byaidu/pdf2zh
```
### 9. 优化 vps 虚拟内存
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/swap.sh)
```
### 10. Focalboard
1. 安装环境
 * [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
 * [Go](https://go.dev/doc/install)
 * [Nodjs](https://nodejs.org/en/download/)
2. 安装依赖
```
sudo apt-get install libgtk-3-dev
sudo apt-get install libwebkit2gtk-4.0-dev
sudo apt-get install autoconf dh-autoreconf
```
  3. 通过docker 安装
```
docker run -it -p -d 80:8000 mattermost/focalboard
```
### 11. SearXNG
```
mkdir my-instance
cd my-instance
export PORT=8088
docker pull searxng/searxng
docker run --restart unless-stopped \
             -d -p ${PORT}:8088 \
             -v "${PWD}/searxng:/etc/searxng" \
             -e "BASE_URL=http://localhost:$PORT/" \
             -e "INSTANCE_NAME=my-instance" \
             searxng/searxng
```
  **之后在 Nginx Proxy Manager 里把 search.domain.com 反代到 8088端口即可**

* ### 其它 Docker 镜像：
  * deep-research-web-ui [https://github.com/AnotiaWang/deep-research-web-ui]
  * WordPress
  * Markitdown
  * Stirling-PDF
  * 雷池 WAF
  * Perplexica

* ### 其它工具
- acme.sh (可以申请支持通配符的证书，自动续期)
