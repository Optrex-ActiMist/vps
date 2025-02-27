# 新建VPS快捷运行脚本：
### 1. 安装 Docker 和 BBR
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/installdocker_with_bbr.sh)
```
### 2. 安装 Docker-compose 
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/install_docker_compose.sh)
```

### 3. 申请 SSL 证书，以下二选一(若安装Nginx，这一步可省略)：
##### - 安装 Cerbot 并使用 Letsencrypt standalone方式申请证书
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/getssl.sh)
```
##### - 安装 acme.sh 并使用 zerossl standalone 方式申请证书
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/getssl_byacme.sh)
```

### 4. 安装 gost 
##### 原版：
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/gostv1.sh)
```
##### 改进版（加上h3支持及多路复用、提高并发）：
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/gostv2.sh)
```

### 5. 安装 Nginx Proxy Manager，申请SSL证书 
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/main/install_NginxProxyManager.sh)
```

### 6. 安装 Portainer(docker管理工具)
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/refs/heads/main/install_Portainer.sh)
```

### 7. 安装 Watchtower （自动更新 docker image）
```
bash <(curl -fsSL https://raw.githubusercontent.com/Optrex-ActiMist/vps/refs/heads/main/install_watchtower.sh)
```

### 8 安装 vocechat (https://doc.voce.chat/)
```
# 运行容器
docker run -d --restart=always \
  -p 3001:3000 \ #3000 端口被deepsearch 占用，所以改为监听3001端口
  --name vocechat-server \
  privoce/vocechat-server:latest
``` 

### 其它 Docker 镜像：
- deep-research-web-ui [https://github.com/AnotiaWang/deep-research-web-ui]
- PDF Math Translate [https://github.com/Byaidu/PDFMathTranslate]
- WordPress
- Markitdown
- Stirling-PDF

### 其它工具
- acme.sh (可以申请支持通配符的证书，自动续期)
- 
