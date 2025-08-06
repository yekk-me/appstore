#!/bin/bash

# --- 加载环境变量 ---
if [ -f .env ]; then
  # 使用 set -a 将从 .env 文件中读取的变量自动导出，
  # 以便它们可用于由该脚本启动的子进程（例如 Docker Compose）。
  set -a
  source .env
  set +a
  echo "已成功从 .env 文件加载环境变量。"
else
  echo "警告: 未找到 .env 文件。将使用系统中已设置的环境变量。"
fi

# --- 创建必要的数据目录 ---
echo "正在创建数据目录..."
mkdir -p ./data/teslamate
mkdir -p ./data/grafana
mkdir -p ./data/postgres
mkdir -p ./data/mosquitto/config
mkdir -p ./data/mosquitto/data
mkdir -p ./data/teslamateapi
mkdir -p ./data/auth
mkdir -p ./data/cloudflared

# --- 设置目录权限 ---
echo "正在设置目录权限..."
chmod -R 755 ./data
# 为 Grafana 设置正确的用户权限 (UID/GID 472)
chown -R 472:472 ./data/grafana 2>/dev/null || true
# 为 TeslaMateAPI 设置权限 (UID/GID 1000)
chown -R 1000:1000 ./data/teslamateapi 2>/dev/null || true

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


echo "Mytesla 初始化完成！"