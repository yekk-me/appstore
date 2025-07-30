# TeslaMate 1Panel 应用部署指南

本文档指导您如何在 1Panel 中部署 TeslaMate 应用。

## 文件结构

```
teslamate/
├── logo.png.txt          # Logo 占位符（需要替换为实际的 logo.png）
├── data.yml              # 应用声明文件
├── README.md             # 应用说明文档
├── DEPLOYMENT.md         # 本部署指南
└── 2.0.0/                # 版本目录
    ├── data.yml          # 参数配置文件
    ├── docker-compose.yml # Docker Compose 配置
    ├── data/             # 数据目录（运行时创建）
    └── scripts/          # 脚本目录
        └── init.sh       # 初始化脚本
```

## 部署步骤

### 1. 准备工作

1. **添加 Logo**：
   - 获取一个 180x180 像素的 PNG 格式 logo
   - 将其命名为 `logo.png`
   - 替换 `logo.png.txt` 文件

2. **上传到 1Panel**：
   ```bash
   # 将整个 teslamate 目录上传到 1Panel 的本地应用目录
   cp -r teslamate /opt/1panel/resource/apps/local/
   ```

### 2. 安装前准备

1. **创建 PostgreSQL 数据库服务**：
   - 在 1Panel 应用商店中先安装 PostgreSQL
   - 记录数据库的连接信息

2. **更新应用列表**：
   - 在 1Panel 应用商店中点击"更新应用列表"
   - 等待同步完成

### 3. 安装应用

1. 在应用商店中找到 TeslaMate 应用
2. 点击安装，填写以下配置：
   - **数据库服务**: 选择已创建的 PostgreSQL 服务
   - **数据库名**: 建议使用默认值（会自动添加随机后缀）
   - **数据库用户**: 建议使用默认值（会自动添加随机后缀）
   - **数据库密码**: 使用自动生成的复杂密码
   - **加密密钥**: 使用自动生成的密钥
   - **端口配置**: 确保端口未被占用
   - **Grafana 配置**: 设置管理员账号和密码
   - **时区**: 选择合适的时区

3. 点击确认安装

### 4. 验证安装

1. **检查服务状态**：
   - 在 1Panel 应用管理中查看 TeslaMate 状态
   - 确保所有容器都正常运行

2. **访问 Web 界面**：
   - TeslaMate: `http://服务器IP:TeslaMate端口`
   - Grafana: `http://服务器IP:Grafana端口`

### 5. 初始配置

1. **配置 TeslaMate**：
   - 访问 TeslaMate Web 界面
   - 按照提示进行特斯拉账号授权
   - 添加您的特斯拉车辆

2. **配置 Grafana**：
   - 使用安装时设置的管理员账号登录
   - 浏览预配置的仪表板

## 故障排除

### 常见问题

1. **容器启动失败**：
   - 检查端口是否被占用
   - 确认数据库服务正常运行
   - 查看容器日志

2. **数据库连接失败**：
   - 确认数据库服务正常
   - 检查数据库连接参数
   - 验证数据库用户权限

3. **权限问题**：
   - 检查数据目录权限
   - 确认初始化脚本执行成功

### 日志查看

```bash
# 查看应用日志
docker logs <container_name>

# 查看初始化脚本日志
cat /opt/1panel/resource/apps/local/teslamate/2.0.0/logs/init.log
```

## 升级说明

当有新版本时：
1. 备份数据目录
2. 在 1Panel 应用管理中点击升级
3. 等待升级完成
4. 验证服务正常

## 注意事项

- 首次启动可能需要几分钟时间初始化
- 建议定期备份 PostgreSQL 数据库
- 确保服务器网络连接稳定
- 定期更新到最新版本

## 支持

如遇问题，请参考：
- [TeslaMate 官方文档](https://docs.teslamate.org/)
- [TeslaMate GitHub](https://github.com/teslamate-org/teslamate)
- [1Panel 官方文档](https://1panel.cn/docs/)