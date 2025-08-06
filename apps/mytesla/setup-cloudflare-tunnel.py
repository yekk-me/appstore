#!/usr/bin/env python3
"""
Cloudflare Tunnel 自动配置脚本
用于自动添加 Public Hostname 到 Cloudflare Tunnel
"""

import os
import sys
import json
import requests
from typing import Dict, List, Optional

class CloudflareTunnelConfigurator:
    def __init__(self):
        self.api_token = os.environ.get('CLOUDFLARE_API_TOKEN')
        self.account_id = os.environ.get('CLOUDFLARE_ACCOUNT_ID')
        self.tunnel_id = os.environ.get('TUNNEL_ID')
        self.domain = os.environ.get('DOMAIN')
        
        self.api_base_url = "https://api.cloudflare.com/client/v4"
        self.headers = {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json"
        }
        
    def validate_environment(self) -> bool:
        """验证必要的环境变量"""
        missing_vars = []
        
        if not self.api_token:
            missing_vars.append("CLOUDFLARE_API_TOKEN")
        if not self.account_id:
            missing_vars.append("CLOUDFLARE_ACCOUNT_ID")
        if not self.tunnel_id:
            missing_vars.append("TUNNEL_ID")
        if not self.domain:
            missing_vars.append("DOMAIN")
            
        if missing_vars:
            print("❌ 缺少必要的环境变量:")
            for var in missing_vars:
                print(f"  - {var}")
            print("\n使用方法:")
            print("export CLOUDFLARE_API_TOKEN='your-api-token'")
            print("export CLOUDFLARE_ACCOUNT_ID='your-account-id'")
            print("export TUNNEL_ID='your-tunnel-id'")
            print("export DOMAIN='mytesla.example.com'")
            print("python3 setup-cloudflare-tunnel.py")
            return False
            
        return True
        
    def get_tunnel_config(self) -> Optional[Dict]:
        """获取当前 Tunnel 配置"""
        url = f"{self.api_base_url}/accounts/{self.account_id}/cfd_tunnel/{self.tunnel_id}/configurations"
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"❌ 获取 Tunnel 配置失败: {e}")
            return None
            
    def check_existing_hostname(self, config: Dict) -> bool:
        """检查域名是否已经配置"""
        ingress_rules = config.get('result', {}).get('config', {}).get('ingress', [])
        
        for rule in ingress_rules:
            if rule.get('hostname') == self.domain:
                return True
                
        return False
        
    def update_tunnel_config(self, current_config: Dict) -> bool:
        """更新 Tunnel 配置"""
        # 获取现有的 ingress 规则
        current_ingress = current_config.get('result', {}).get('config', {}).get('ingress', [])
        
        # 创建新的 ingress 规则
        new_rule = {
            "hostname": self.domain,
            "service": "http://traefik:80",
            "originRequest": {}
        }
        
        # 过滤掉 catch-all 规则（如果存在）
        filtered_ingress = [rule for rule in current_ingress if rule.get('hostname') is not None]
        
        # 添加新规则
        filtered_ingress.append(new_rule)
        
        # 添加 catch-all 规则（必须在最后）
        filtered_ingress.append({"service": "http_status:404"})
        
        # 构建更新配置
        update_config = {
            "config": {
                "ingress": filtered_ingress
            }
        }
        
        # 发送更新请求
        url = f"{self.api_base_url}/accounts/{self.account_id}/cfd_tunnel/{self.tunnel_id}/configurations"
        
        try:
            response = requests.put(url, headers=self.headers, json=update_config)
            response.raise_for_status()
            
            result = response.json()
            if result.get('success'):
                return True
            else:
                print(f"❌ 更新失败: {result.get('errors', 'Unknown error')}")
                return False
                
        except requests.exceptions.RequestException as e:
            print(f"❌ 更新 Tunnel 配置失败: {e}")
            return False
            
    def run(self):
        """执行配置流程"""
        print("🚀 Cloudflare Tunnel 域名自动配置脚本")
        print("=" * 50)
        
        # 验证环境变量
        if not self.validate_environment():
            return False
            
        print(f"📋 配置信息:")
        print(f"  - 域名: {self.domain}")
        print(f"  - Tunnel ID: {self.tunnel_id}")
        print(f"  - 服务: http://traefik:80")
        print()
        
        # 获取当前配置
        print("📡 获取当前 Tunnel 配置...")
        current_config = self.get_tunnel_config()
        if not current_config:
            return False
            
        # 检查域名是否已存在
        if self.check_existing_hostname(current_config):
            print(f"⚠️  域名 {self.domain} 已经配置在 Tunnel 中")
            print("   如需更新配置，请先删除现有配置")
            return True
            
        # 更新配置
        print("🔄 正在更新 Tunnel 配置...")
        if self.update_tunnel_config(current_config):
            print(f"✅ 成功配置域名 {self.domain} 到 Cloudflare Tunnel")
            print(f"   Service: http://traefik:80")
            print()
            print("📌 请确保:")
            print("  1. 您的域名 DNS 已经指向 Cloudflare")
            print("  2. Cloudflare Tunnel 正在运行")
            print("  3. Traefik 服务正在运行")
            print()
            print(f"🌐 您现在可以通过 https://{self.domain} 访问您的服务")
            return True
        else:
            return False

def main():
    configurator = CloudflareTunnelConfigurator()
    success = configurator.run()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()