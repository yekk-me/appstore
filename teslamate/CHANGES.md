# TeslaMate 1Panel 应用更改说明

## 主要变更

基于用户需求，已将应用配置从依赖外部 PostgreSQL 数据库改为使用内置数据库。

### 变更详情

#### 1. Docker Compose 配置变更

**添加了内置服务：**
- ✅ PostgreSQL 17 数据库服务
- ✅ Eclipse Mosquitto MQTT 服务

**服务依赖关系：**
- TeslaMate 服务依赖：database + mosquitto
- Grafana 服务依赖：database
- 所有服务使用内部容器名进行通信

#### 2. 参数配置变更

**移除的配置项：**
- ❌ 数据库服务选择（`type: service`）
- ❌ 外部数据库主机配置

**保留的配置项：**
- ✅ 数据库名称（自动添加随机后缀）
- ✅ 数据库用户（自动添加随机后缀）  
- ✅ 数据库密码（自动生成复杂密码）
- ✅ TeslaMate 加密密钥
- ✅ 端口配置（TeslaMate + Grafana）
- ✅ Grafana 管理员配置
- ✅ 时区选择

#### 3. 文档更新

**README.md 更新：**
- 更新安装要求说明
- 强调内置组件特性
- 简化安装步骤

**DEPLOYMENT.md 更新：**
- 移除外部数据库安装步骤
- 更新故障排除指南
- 调整配置参数说明

## 优势

### 1. 简化部署
- 🚀 一键安装，无需预先安装依赖
- 🔧 自动配置数据库连接
- 📦 完整的服务栈打包

### 2. 更好的隔离性
- 🔒 数据库完全隔离在应用容器中
- 🛡️ 避免与系统数据库冲突
- 🔐 独立的数据库用户和权限

### 3. 便于管理
- 📊 统一的容器管理
- 🔄 简化的备份和恢复
- ⚡ 更快的启动和停止

## 数据持久化

所有数据存储在 `./data/` 目录下：
```
data/
├── postgres/          # PostgreSQL 数据文件
├── grafana/           # Grafana 配置和仪表板
├── teslamate/         # TeslaMate 导入数据
└── mosquitto/         # MQTT 配置和数据
    ├── config/
    └── data/
```

## 升级兼容性

- ✅ 支持跨版本升级（`crossVersionUpdate: true`）
- ✅ 数据目录自动迁移
- ✅ 配置参数向后兼容

## 注意事项

1. **首次启动时间**：由于需要初始化 PostgreSQL 数据库，首次启动可能需要 2-3 分钟
2. **资源需求**：内置数据库会增加内存和存储需求
3. **备份建议**：定期备份 `./data/postgres/` 目录
4. **端口占用**：确保 TeslaMate 和 Grafana 端口未被占用

## 验证方法

安装完成后，可以通过以下方式验证：

```bash
# 检查所有容器状态
docker ps | grep teslamate

# 查看数据库连接
docker logs <teslamate-container-name>

# 验证 Grafana 连接
docker logs <grafana-container-name>
```

预期看到 4 个容器正常运行：
- teslamate
- teslamate-grafana  
- teslamate-database
- teslamate-mosquitto