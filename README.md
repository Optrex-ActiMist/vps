# 新建VPS快捷运行脚本：
### 1. 安装 Docker 和 BBR
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/installdocker_with_bbr.sh)
```
### 2. 安装 Docker-compose 
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/install_docker_compose.sh)
```

### 3. 申请 SSL 证书，以下二选一：
  - 安装 Cerbot 并使用 Letsencrypt 申请证书
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/getssl.sh)
```
- 安装 acme.sh 并使用 Letsencrypt 申请证书
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/getssl_byacme.sh)
```

### 4. 安装 gost 
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/gost.sh)
```

### 5. 安装 Nginx Proxy Manager，申请SSL证书

### 其它 Docker 镜像：
- Portainer (docker管理工具)
- deep-research-web-ui [https://github.com/AnotiaWang/deep-research-web-ui]
- Watchtower （自动更新 docker image）
- WordPress
- 微软 Markitdown
- PDF Math Translate [https://github.com/Byaidu/PDFMathTranslate]
- Send [https://send.vis.ee/]
- Stirling-PDF 
