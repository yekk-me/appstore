#!/bin/bash

# 创建必要的数据目录
mkdir -p ./data/teslamate
mkdir -p ./data/grafana
mkdir -p ./data/postgres
mkdir -p ./data/mosquitto/config
mkdir -p ./data/mosquitto/data
mkdir -p ./data/teslamateapi
mkdir -p ./data/tailscale/state
mkdir -p ./data/tailscale/socket

# 设置目录权限
chmod -R 755 ./data

# 为 Grafana 设置正确的用户权限
chown -R 472:472 ./data/grafana 2>/dev/null || true

# 为 TeslaMateAPI 设置权限
chown -R 1000:1000 ./data/teslamateapi 2>/dev/null || true

echo "Mytesla 初始化完成"