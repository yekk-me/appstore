#!/bin/bash

# Cloudflare Tunnel 域名配置助手脚本
# 使用 cloudflared CLI 工具配置域名

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Cloudflare Tunnel 域名配置助手 ===${NC}"
echo

# 检查是否安装了 cloudflared
if ! command -v cloudflared &> /dev/null; then
    echo -e "${YELLOW}cloudflared CLI 工具未安装${NC}"
    echo "正在安装 cloudflared..."
    
    # 检测系统架构
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            CLOUDFLARED_ARCH="amd64"
            ;;
        aarch64|arm64)
            CLOUDFLARED_ARCH="arm64"
            ;;
        *)
            echo -e "${RED}不支持的系统架构: $ARCH${NC}"
            exit 1
            ;;
    esac
    
    # 下载并安装 cloudflared
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CLOUDFLARED_ARCH} -O /tmp/cloudflared
    chmod +x /tmp/cloudflared
    sudo mv /tmp/cloudflared /usr/local/bin/
    
    echo -e "${GREEN}✅ cloudflared 安装成功${NC}"
fi

# 读取配置
if [ -f ".env" ]; then
    source .env
fi

# 获取用户输入
if [ -z "$CLOUDFLARE_DOMAIN" ]; then
    read -p "请输入您要配置的域名 (例如: mytesla.example.com): " CLOUDFLARE_DOMAIN
fi

if [ -z "$CLOUDFLARE_TUNNEL_TOKEN" ]; then
    echo -e "${YELLOW}请提供 Cloudflare Tunnel Token${NC}"
    echo "您可以从 Cloudflare Zero Trust Dashboard > Access > Tunnels 获取"
    read -p "Tunnel Token: " CLOUDFLARE_TUNNEL_TOKEN
fi

# 显示配置信息
echo
echo -e "${BLUE}配置信息:${NC}"
echo -e "  域名: ${GREEN}$CLOUDFLARE_DOMAIN${NC}"
echo -e "  服务: ${GREEN}http://traefik:80${NC}"
echo

# 创建配置文件
CONFIG_FILE="/tmp/tunnel-config.yml"
cat > $CONFIG_FILE << EOF
ingress:
  - hostname: $CLOUDFLARE_DOMAIN
    service: http://traefik:80
  - service: http_status:404
EOF

echo -e "${YELLOW}配置内容:${NC}"
cat $CONFIG_FILE
echo

# 提示用户如何配置
echo -e "${BLUE}配置步骤:${NC}"
echo
echo "1. 登录 Cloudflare Zero Trust Dashboard:"
echo "   https://one.dash.cloudflare.com/"
echo
echo "2. 导航到 Access > Tunnels"
echo
echo "3. 找到您的 Tunnel 并点击配置"
echo
echo "4. 在 Public Hostname 标签页中添加:"
echo -e "   - Subdomain: ${GREEN}${CLOUDFLARE_DOMAIN%%.*}${NC}"
echo -e "   - Domain: ${GREEN}${CLOUDFLARE_DOMAIN#*.}${NC}"
echo -e "   - Type: ${GREEN}HTTP${NC}"
echo -e "   - URL: ${GREEN}traefik:80${NC}"
echo
echo "5. 保存配置"
echo

# 更新 .env 文件
if [ -f ".env" ]; then
    if ! grep -q "CLOUDFLARE_DOMAIN=" .env; then
        echo "CLOUDFLARE_DOMAIN=$CLOUDFLARE_DOMAIN" >> .env
        echo -e "${GREEN}✅ 已将域名配置保存到 .env 文件${NC}"
    fi
fi

echo -e "${BLUE}Docker Compose 配置已更新${NC}"
echo "您现在可以运行以下命令启动服务:"
echo -e "${GREEN}docker compose up -d${NC}"
echo
echo "服务启动后，您可以通过以下地址访问:"
echo -e "  ${GREEN}https://$CLOUDFLARE_DOMAIN${NC} - TeslaMate 主界面"
echo -e "  ${GREEN}https://$CLOUDFLARE_DOMAIN/grafana${NC} - Grafana 仪表板"
echo -e "  ${GREEN}https://$CLOUDFLARE_DOMAIN/api${NC} - TeslaMate API"