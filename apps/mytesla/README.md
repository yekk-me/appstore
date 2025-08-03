# Mytesla

Mytesla 是一个功能强大的特斯拉车辆数据自托管记录器，集成了 TeslaMate、Grafana 数据可视化和 TeslaMateAPI，支持 Tailscale 零配置 VPN 安全访问。

## 功能特性

- 📊 **数据记录**: 自动记录驾驶、充电、软件更新等数据
- 📈 **数据可视化**: 内置 Grafana 仪表板，提供丰富的数据图表
- 🔒 **隐私保护**: 数据完全存储在您的服务器上
- 🚗 **多车辆支持**: 支持同时记录多辆特斯拉车辆
- 📱 **Web 界面**: 提供友好的 Web 管理界面
- 🌐 **API 接口**: 提供 TeslaMateAPI RESTful 接口
- 🔐 **安全访问**: 集成 Tailscale VPN，支持安全的远程访问

## 安装要求

### 内置组件
- TeslaMate (特斯拉数据收集器)
- PostgreSQL 数据库（内置，自动部署）
- MQTT 消息队列（内置，自动部署）
- Grafana 数据可视化（内置，自动部署）
- TeslaMateAPI RESTful 接口（内置，自动部署）
- Tailscale VPN 客户端（内置，自动部署）
- Traefik 反向代理（内置，自动部署）

### 端口说明
- **TeslaMate**: 默认端口 4000，用于 Web 管理界面
- **Grafana**: 默认端口 3000，用于数据可视化仪表板
- **TeslaMateAPI**: 默认端口 8080，用于 RESTful API 接口

## 首次配置

### 1. 准备 Tailscale 配置

在安装应用之前，您需要准备 Tailscale 相关配置：

1. **注册 Tailscale 账号**
   - 访问 [Tailscale 官网](https://tailscale.com/) 注册账号
   - 可以使用 Google、Microsoft 或 GitHub 账号登录

2. **获取认证密钥**
   - 登录 [Tailscale 管理控制台](https://login.tailscale.com/admin/settings/keys)
   - 点击 "Generate auth key" 生成认证密钥
   - ⚠️ **重要**: 密钥只显示一次，请妥善保存

3. **获取 Tailnet 名称**
   - 在 [Tailscale DNS 设置](https://login.tailscale.com/admin/dns) 页面
   - 找到您的 Tailnet 域名 (例如: `your-name.ts.net`)

### 2. 安装应用

在 1Panel 应用商店中找到 Mytesla，点击安装并填写以下必要配置：

#### Tailscale 配置
- **Tailscale Auth Key**: 从步骤1获取的认证密钥
- **Tailscale Tailnet Name**: 您的 Tailnet 域名 (例如: `your-name.ts.net`)

#### API 安全配置
- **API Token**: 系统会自动生成，用于 TeslaMateAPI 安全认证

#### 其他配置
- 数据库配置：系统会自动生成安全的随机密码
- 端口配置：根据需要调整端口号
- Grafana 管理员账号：设置 Grafana 的登录密码

### 3. 配置 TeslaMate

安装完成后：

1. **本地访问**: 访问 `http://你的服务器IP:4000` 进入 TeslaMate 管理界面
2. **Tailscale 访问**: 访问 `https://mytesla.你的Tailnet名称` (需要设备已连接 Tailscale)
3. 按照界面提示进行特斯拉账号授权
4. 添加您的特斯拉车辆

### 4. 访问 Grafana 仪表板

1. **本地访问**: 访问 `http://你的服务器IP:3000`
2. **Tailscale 访问**: 访问 `https://mytesla.你的Tailnet名称/grafana`
3. 使用安装时设置的管理员账号登录
4. 浏览预配置的仪表板查看车辆数据

### 5. 配置 Tailscale 客户端访问

要从其他设备访问您的 Mytesla 服务：

1. 在您的手机、电脑等设备上安装 [Tailscale 客户端](https://tailscale.com/download)
2. 使用同一个 Tailscale 账号登录
3. 连接成功后即可通过以下地址访问服务

### 6. 设置 Tailscale 节点不过期

⚠️ **重要步骤**: 

1. 访问 [Tailscale 设备管理](https://login.tailscale.com/admin/machines)
2. 找到名为 `mytesla` 的节点
3. 点击设置，选择 "Disable key expiry"
4. 这样可以防止节点过期导致服务无法访问

## 访问地址总览

安装完成后，请记录以下访问地址，这些信息在配置 Mytesla.cc 时会用到：

### 🌐 通过 Tailscale 访问 (推荐)
- **TeslaMate 主界面**: `https://mytesla.你的Tailnet名称`
- **Grafana 仪表板**: `https://mytesla.你的Tailnet名称/grafana`
- **API 接口**: `https://mytesla.你的Tailnet名称/api`
- **API 测试**: `https://mytesla.你的Tailnet名称/api/ping`

### 🏠 本地网络访问
- **TeslaMate 主界面**: `http://服务器IP:4000`
- **Grafana 仪表板**: `http://服务器IP:3000`
- **API 接口**: `http://服务器IP:8080`

## 在 Mytesla.cc 中配置

完成部署后，您可以在 [Mytesla.cc](https://mytesla.cc) 中配置远程访问：

1. 访问 [https://mytesla.cc](https://mytesla.cc)
2. 进入 Settings → TeslaMate 配置
3. 填写以下信息：
   - **API 地址**: `https://mytesla.你的Tailnet名称`
   - **API Token**: 安装时生成的 API Token (在应用详情中可查看)
4. 点击测试连接验证配置
5. 配置成功后即可在 Mytesla.cc 中查看和管理您的特斯拉数据

## 数据安全

- ✅ 所有数据都存储在您的本地服务器上
- ✅ 支持数据加密存储
- ✅ API 接口使用 Token 进行安全认证
- ✅ Tailscale 提供端到端加密连接
- ✅ 建议定期备份 PostgreSQL 数据库

## 故障排除

### 常见问题

1. **无法通过 Tailscale 访问服务**
   - 检查 Tailscale 服务是否正常运行：`docker logs mytesla-tailscale`
   - 确认设备已连接到同一个 Tailnet
   - 验证 Tailscale 节点未过期

2. **无法连接特斯拉账号**
   - 检查网络连接
   - 确认特斯拉账号和密码正确
   - 查看 TeslaMate 日志获取详细错误信息

3. **Grafana 无法显示数据**
   - 确认数据库连接正常
   - 检查 TeslaMate 是否成功收集到数据
   - 验证 Grafana 数据源配置

4. **API 接口无法访问**
   - 检查 TeslaMateAPI 服务状态
   - 验证 API Token 配置正确
   - 测试 API 连通性：访问 `/api/ping` 端点

5. **服务启动失败**
   - 检查端口是否被占用
   - 确认数据库服务正常运行
   - 查看容器日志排查具体问题

### 日志查看

```bash
# 查看所有服务状态
docker ps

# 查看特定服务日志
docker logs mytesla                    # TeslaMate
docker logs mytesla-grafana           # Grafana
docker logs mytesla-teslamateapi      # TeslaMateAPI
docker logs mytesla-tailscale         # Tailscale
docker logs mytesla-traefik           # Traefik
```

## 更多信息

- [TeslaMate 官方文档](https://docs.teslamate.org/)
- [Grafana 官方文档](https://grafana.com/docs/)
- [Tailscale 官方文档](https://tailscale.com/kb/)
- [Mytesla.cc 官网](https://mytesla.cc/)

## 注意事项

- 首次启动可能需要几分钟时间初始化数据库和 Tailscale 连接
- 建议在稳定的网络环境下运行
- 定期更新到最新版本以获得最佳体验
- 妥善保管 API Token 和 Tailscale 认证密钥