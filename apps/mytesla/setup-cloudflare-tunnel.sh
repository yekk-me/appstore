#!/bin/bash

# Cloudflare Tunnel 自动配置脚本
# 用于自动添加 Public Hostname 到 Cloudflare Tunnel

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Cloudflare Tunnel 域名自动配置脚本 ===${NC}"
echo

# 检查必要的环境变量
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${YELLOW}请设置 CLOUDFLARE_API_TOKEN 环境变量${NC}"
    echo "您可以在 https://dash.cloudflare.com/profile/api-tokens 创建 API Token"
    echo "需要的权限: Account:Cloudflare Tunnel:Edit"
    exit 1
fi

if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
    echo -e "${YELLOW}请设置 CLOUDFLARE_ACCOUNT_ID 环境变量${NC}"
    echo "您可以在 Cloudflare 仪表板右侧找到 Account ID"
    exit 1
fi

if [ -z "$TUNNEL_ID" ]; then
    echo -e "${YELLOW}请设置 TUNNEL_ID 环境变量${NC}"
    echo "您可以在 Cloudflare Zero Trust Dashboard > Access > Tunnels 中找到 Tunnel ID"
    exit 1
fi

if [ -z "$DOMAIN" ]; then
    echo -e "${YELLOW}请设置 DOMAIN 环境变量${NC}"
    echo "例如: mytesla.example.com"
    exit 1
fi

# Cloudflare API 基础 URL
API_BASE_URL="https://api.cloudflare.com/client/v4"

# 获取当前 Tunnel 配置
echo -e "${YELLOW}获取当前 Tunnel 配置...${NC}"
TUNNEL_CONFIG=$(curl -s -X GET \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    "$API_BASE_URL/accounts/$CLOUDFLARE_ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations")

if [ $? -ne 0 ]; then
    echo -e "${RED}获取 Tunnel 配置失败${NC}"
    exit 1
fi

# 检查是否已存在该域名的配置
EXISTING_HOSTNAME=$(echo "$TUNNEL_CONFIG" | jq -r '.result.config.ingress[] | select(.hostname == "'$DOMAIN'") | .hostname' 2>/dev/null || echo "")

if [ ! -z "$EXISTING_HOSTNAME" ]; then
    echo -e "${YELLOW}域名 $DOMAIN 已经配置在 Tunnel 中${NC}"
    echo "如果需要更新配置，请先删除现有配置"
    exit 0
fi

# 获取现有的 ingress 规则
CURRENT_INGRESS=$(echo "$TUNNEL_CONFIG" | jq '.result.config.ingress // []' 2>/dev/null || echo "[]")

# 创建新的 ingress 规则
NEW_INGRESS_RULE=$(cat <<EOF
{
  "hostname": "$DOMAIN",
  "service": "http://traefik:80",
  "originRequest": {}
}
EOF
)

# 将新规则添加到现有规则的开头（catch-all 规则必须在最后）
if [ "$CURRENT_INGRESS" = "[]" ]; then
    # 如果没有现有规则，创建包含新规则和 catch-all 的数组
    UPDATED_INGRESS=$(cat <<EOF
[
  $NEW_INGRESS_RULE,
  {
    "service": "http_status:404"
  }
]
EOF
)
else
    # 从现有规则中移除 catch-all（如果存在）
    INGRESS_WITHOUT_CATCHALL=$(echo "$CURRENT_INGRESS" | jq 'map(select(.hostname != null))')
    
    # 添加新规则和 catch-all
    UPDATED_INGRESS=$(echo "$INGRESS_WITHOUT_CATCHALL" | jq ". + [$NEW_INGRESS_RULE] + [{\"service\": \"http_status:404\"}]")
fi

# 构建完整的配置
UPDATED_CONFIG=$(cat <<EOF
{
  "config": {
    "ingress": $UPDATED_INGRESS
  }
}
EOF
)

# 更新 Tunnel 配置
echo -e "${YELLOW}正在更新 Tunnel 配置...${NC}"
UPDATE_RESPONSE=$(curl -s -X PUT \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$UPDATED_CONFIG" \
    "$API_BASE_URL/accounts/$CLOUDFLARE_ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations")

if [ $? -ne 0 ]; then
    echo -e "${RED}更新 Tunnel 配置失败${NC}"
    echo "响应: $UPDATE_RESPONSE"
    exit 1
fi

# 检查更新是否成功
SUCCESS=$(echo "$UPDATE_RESPONSE" | jq -r '.success' 2>/dev/null || echo "false")

if [ "$SUCCESS" = "true" ]; then
    echo -e "${GREEN}✅ 成功配置域名 $DOMAIN 到 Cloudflare Tunnel${NC}"
    echo -e "${GREEN}   Service: http://traefik:80${NC}"
    echo
    echo -e "${YELLOW}请确保:${NC}"
    echo "1. 您的域名 DNS 已经指向 Cloudflare"
    echo "2. Cloudflare Tunnel 正在运行"
    echo "3. Traefik 服务正在运行"
    echo
    echo -e "${GREEN}您现在可以通过 https://$DOMAIN 访问您的服务${NC}"
else
    echo -e "${RED}更新失败${NC}"
    echo "错误信息:"
    echo "$UPDATE_RESPONSE" | jq '.'
    exit 1
fi