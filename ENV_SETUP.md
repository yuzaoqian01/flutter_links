# 环境变量配置说明

## 创建 .env 文件

在项目根目录创建 `.env` 文件，包含以下配置：

```bash
# Supabase配置
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# 以太坊RPC配置
# 从 https://infura.io 获取您的项目ID
ETH_MAIN_KEY=your_infura_project_id_here

# 其他网络RPC URL（可选）
POLYGON_RPC_URL=https://polygon-rpc.com
BSC_RPC_URL=https://bsc-dataseed.binance.org

# 日志配置
SHOW_SUPABASE_LOGS=false
SUPABASE_DEBUG=false
```

## 获取 Infura 项目 ID

1. 访问 [Infura](https://infura.io)
2. 注册并登录账户
3. 创建新项目
4. 在项目设置中获取项目ID
5. 将项目ID填入 `ETH_MAIN_KEY`

## 获取 Supabase 配置

1. 访问 [Supabase](https://supabase.com)
2. 创建新项目
3. 在项目设置中获取：
   - Project URL → `SUPABASE_URL`
   - anon public key → `SUPABASE_ANON_KEY`

## 注意事项

- `.env` 文件已添加到 `.gitignore`，不会被提交到版本控制
- 确保在生产环境中使用正确的API密钥
- 不要将真实的API密钥提交到公共仓库

## 验证配置

运行应用后，检查控制台日志确认：
- 环境变量加载成功
- 钱包服务初始化正常
- 网络连接正常 