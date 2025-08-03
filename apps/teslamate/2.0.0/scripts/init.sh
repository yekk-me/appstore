#!/bin/bash

# 创建必要的数据目录
mkdir -p ./data/teslamate
mkdir -p ./data/grafana
mkdir -p ./data/postgres
mkdir -p ./data/mosquitto/config
mkdir -p ./data/mosquitto/data

# 设置目录权限
chmod -R 755 ./data

# 为 Grafana 设置正确的用户权限
chown -R 472:472 ./data/grafana 2>/dev/null || true

echo "TeslaMate 初始化完成"