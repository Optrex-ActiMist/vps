#!/bin/bash

# 脚本在遇到任何错误时立即退出
set -e
# 确保管道中的任何命令失败都会导致整个管道失败
set -o pipefail

# --- 预检查 ---

# 检查 sudo 权限 (移到最前)
if ! command -v sudo &> /dev/null || ! sudo -n true 2>/dev/null; then
    echo "❌ 错误：需要 sudo 权限运行此脚本。" >&2
    exit 1
fi

# 检查 Docker 是否已安装 (使用 sudo 确保权限)
if command -v docker &> /dev/null && sudo docker compose version &> /dev/null; then
    echo "✅ Docker 和 Docker Compose 已经安装。"
    echo "   Docker 版本: $(sudo docker --version)"
    echo "   Docker Compose 版本: $(sudo docker compose version)"
    exit 0
fi

# 检查系统兼容性 (Debian/Ubuntu)
if ! grep -qE '^(debian|ubuntu)' /etc/os-release; then
    echo "❌ 错误：此脚本仅支持 Debian 或 Ubuntu 系统。" >&2
    exit 1
fi

# 提示用户确认域名是否已解析到 VPS 的 IP 地址
echo "请问您是否已经将域名解析至 VPS 的 IP 地址？"
echo "请输入 'y' 确认，或者其他键退出："
read answer
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "脚本已退出，请先解析域名后再运行。"
    echo "提示：请确保域名 A 记录指向 VPS 的公网 IP，可通过 DNS 提供商配置。"
    exit 1
fi

# --- 开始安装 ---
echo "⚙️ 开始安装 Docker 和 Docker Compose..."

# 清理旧版本
echo "   - 正在卸载旧版本 Docker (如有)..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# 更新 apt 索引并安装依赖
echo "   - 正在更新软件包列表并安装依赖..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release
    
# 添加 Docker 的官方 GPG 密钥
echo "   - 正在添加 Docker 官方 GPG 密钥..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg \
 | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
if [ $? -ne 0 ]; then
    echo "❌ 错误：无法下载 Docker GPG 密钥，请检查网络连接。" >&2
    exit 1
fi 
sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
# 添加 Docker 的 APT 软件源
echo "   - 正在配置 Docker APT 软件源..."
# 使用变量存储架构和发行版代号
ARCH=$(dpkg --print-architecture)
OS_ID=$(. /etc/os-release && echo "$ID")
OS_CODENAME=$(lsb_release -cs)

echo \
  "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS_ID} \
  ${OS_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# --------------------------------------------------
# 关键修复：在添加新源后，必须再次更新 apt 列表
# --------------------------------------------------
echo "   - 正在更新软件包列表以包含 Docker 源..."
sudo apt-get update -y

# 安装 Docker Engine + 官方插件（包括 compose） 
echo "   - 正在安装 Docker 引擎和插件..."
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# 启动 Docker 并设置为开机自启
echo "   - 正在启动并设置 Docker 开机自启..."
sudo systemctl enable --now docker

# 将当前用户添加到 docker 组以实现免 sudo
echo "   - 正在将当前用户 ($USER) 添加到 'docker' 组..."
sudo usermod -aG docker $USER

# --- 验证安装 ---
echo ""
echo "✅ Docker 和 Docker Compose 安装成功！"
echo ""
# 关键修复：使用 sudo 验证，因为当前会话权限尚未更新
echo "   Docker 版本: $(sudo docker --version)"
echo "   Docker Compose 版本: $(sudo docker compose version)"
echo ""
echo "⚠️ 重要提示："
echo "   为了使 'docker' 组权限生效（即无需 sudo 运行 docker），"
echo "   您需要退出当前 SSH 会话并重新登录。"
