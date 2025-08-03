# Mytesla (TeslaMate + Tailscale)

Mytesla 是一个完整的特斯拉车辆数据记录和可视化解决方案，集成了 TeslaMate、Grafana、TeslaMateAPI 和 Tailscale 安全访问。

## 功能特性

- 📊 **完整数据记录**: 自动记录驾驶、充电、软件更新等数据
- 📈 **数据可视化**: 内置 Grafana 仪表板，提供丰富的数据图表
- 🔒 **安全远程访问**: 通过 Tailscale VPN 安全访问您的数据
- 🚗 **多车辆支持**: 支持同时记录多辆特斯拉车辆
- 📱 **API 接口**: 提供 RESTful API 用于第三方应用集成
- 🌐 **Mytesla.cc 集成**: 支持与 Mytesla.cc 平台无缝对接

## 组件说明

### 内置组件
- **TeslaMate**: 特斯拉数据记录核心服务
- **PostgreSQL**: 数据库存储
- **MQTT**: 实时消息传递
- **Grafana**: 数据可视化仪表板
- **TeslaMateAPI**: RESTful API 服务
- **Tailscale**: 零配置 VPN 服务
- **Traefik**: 反向代理和负载均衡

### 端口说明
- **TeslaMate**: 默认端口 4000
- **Grafana**: 默认端口 3000
- **TeslaMateAPI**: 默认端口 8080

## 首次配置

### 1. 获取 Tailscale 认证密钥

1. 访问 [Tailscale 官网](https://tailscale.com/) 注册账号
2. 登录 [Tailscale 管理控制台](https://login.tailscale.com/admin/settings/keys)
3. 点击 "Generate auth key" 生成认证密钥
4. 记录您的 Tailnet 域名（在 DNS 页面可以找到，格式如: your-name.ts.net）

### 2. 安装应用

在 1Panel 应用商店中安装 Mytesla 时需要填写：
- **Tailscale Auth Key**: 上一步获取的认证密钥
- **Tailscale Tailnet Name**: 您的 Tailnet 域名（如: your-name.ts.net）
- **API Token**: （可选）用于保护 API 访问的令牌

### 3. 配置 TeslaMate

安装完成后，访问 `http://您的服务器IP:4000` 进行初始配置：
1. 按照界面提示进行特斯拉账号授权
2. 添加您的特斯拉车辆

### 4. 更新 Tailscale 节点设置

重要：在 [Tailscale 控制台](https://login.tailscale.com/admin/machines) 中找到 "mytesla" 节点，在设置中选择 "Disable key expiry"，否则节点会过期导致服务无法访问。

### 5. 远程访问配置

配置完成后，您可以通过以下地址安全访问服务：

- **TeslaMate 主界面**: `https://mytesla.您的Tailnet名称`
- **Grafana 仪表板**: `https://mytesla.您的Tailnet名称/grafana`
- **API 端点**: `https://mytesla.您的Tailnet名称/api`

**请记录以下信息，在 Mytesla.cc 配置时需要使用：**
- API 地址: `https://mytesla.您的Tailnet名称`
- API Token: 安装时设置的 API 令牌

### 6. 在 Mytesla.cc 配置

1. 访问 [https://mytesla.cc](https://mytesla.cc)
2. 进入 Settings → TeslaMate
3. 输入 API 地址：`https://mytesla.您的Tailnet名称`
4. 如果设置了 API Token，在 API Token 字段中输入
5. 点击测试连接

## 故障排除

### 常见问题

1. **无法通过 Tailscale 访问服务**
   - 确认 Tailscale 认证密钥正确
   - 检查节点是否已禁用密钥过期
   - 确保客户端已连接到同一 Tailnet

2. **API 连接失败**
   - 验证 API Token 是否正确
   - 检查 TeslaMateAPI 服务是否正常运行
   - 访问 `/api/ping` 端点测试连接

3. **Grafana 无法访问**
   - 确认使用正确的路径 `/grafana`
   - 检查 Grafana 管理员密码
   - 查看容器日志排查问题

### 查看服务状态

```bash
# 查看所有容器状态
docker ps | grep mytesla

# 查看特定服务日志
docker logs mytesla-tailscale
docker logs mytesla
docker logs mytesla-teslamateapi
```

## 数据安全

- 所有数据都存储在您的本地服务器上
- Tailscale 提供端到端加密的安全连接
- API Token 保护 API 访问安全
- 建议定期备份 PostgreSQL 数据库

## 更多信息

- [TeslaMate 官方文档](https://docs.teslamate.org/)
- [Tailscale 文档](https://tailscale.com/kb/)
- [Mytesla.cc 平台](https://mytesla.cc)
- [GitHub 项目](https://github.com/teslamate-org/teslamate)

## 注意事项

- 首次启动可能需要几分钟时间初始化所有服务
- 确保 Tailscale 节点已禁用密钥过期
- 定期更新到最新版本以获得最佳体验
- 记录好 API 地址和 Token 以便在 Mytesla.cc 配置使用