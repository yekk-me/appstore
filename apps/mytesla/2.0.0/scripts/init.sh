#!/bin/bash

# 创建必要的数据目录
mkdir -p ./data/teslamate
mkdir -p ./data/grafana
mkdir -p ./data/postgres
mkdir -p ./data/mosquitto/config
mkdir -p ./data/mosquitto/data
mkdir -p ./data/teslamateapi
mkdir -p ./data/auth
mkdir -p ./data/cloudflared

# 设置目录权限
chmod -R 755 ./data

# 为 Grafana 设置正确的用户权限
chown -R 472:472 ./data/grafana 2>/dev/null || true

# 为 TeslaMateAPI 设置权限
chown -R 1000:1000 ./data/teslamateapi 2>/dev/null || true

# 生成 Basic Auth 密码文件
if [ ! -f ./data/auth/.htpasswd ]; then
    if [ -n "$BASIC_AUTH_USER" ] && [ -n "$BASIC_AUTH_PASS" ]; then
        # 安装 htpasswd 工具（如果不存在）
        if ! command -v htpasswd &> /dev/null; then
            if command -v apt-get &> /dev/null; then
                apt-get update && apt-get install -y apache2-utils
            elif command -v yum &> /dev/null; then
                yum install -y httpd-tools
            fi
        fi
        
        # 生成 .htpasswd 文件
        if command -v htpasswd &> /dev/null; then
            htpasswd -cb ./data/auth/.htpasswd "$BASIC_AUTH_USER" "$BASIC_AUTH_PASS"
            echo "Basic Auth 配置已生成"
        else
            echo "警告: 无法生成 Basic Auth 配置，htpasswd 工具未找到"
        fi
    else
        echo "警告: BASIC_AUTH_USER 或 BASIC_AUTH_PASS 未设置"
    fi
fi

# 生成 Cloudflare Tunnel 配置文件
if [ -n "$CLOUDFLARE_TUNNEL_TOKEN" ] && [ -n "$CLOUDFLARE_DOMAIN" ]; then
    echo "正在生成 Cloudflare Tunnel 配置..."
    
    # 创建 cloudflared 配置文件
    cat > ./data/cloudflared/config.yml << EOF
# Cloudflare Tunnel 配置
# 自动生成于 $(date)

tunnel: $CLOUDFLARE_TUNNEL_TOKEN

# Ingress 规则
ingress:
  # 主域名路由到 Traefik
  - hostname: $CLOUDFLARE_DOMAIN
    service: http://traefik:80
    originRequest:
      # 不验证 SSL（内部服务）
      noTLSVerify: true
      # 保持原始主机头
      httpHostHeader: $CLOUDFLARE_DOMAIN
  
  # 404 规则（必须在最后）
  - service: http_status:404
EOF
    
    echo "Cloudflare Tunnel 配置已生成"
    echo "  - 域名: $CLOUDFLARE_DOMAIN"
    echo "  - 服务: http://traefik:80"
else
    echo "警告: CLOUDFLARE_TUNNEL_TOKEN 或 CLOUDFLARE_DOMAIN 未设置"
    echo "Cloudflare Tunnel 将使用 Token 模式运行"
fi

echo "Mytesla 初始化完成"