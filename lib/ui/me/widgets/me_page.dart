import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3_links/core/auth/supabase_state_manager.dart';
import 'package:web3_links/ui/home/view_models/wallet_view_model.dart';
import 'package:web3_links/ui/me/widgets/user_profile.dart';
import 'package:web3_links/utils/logger.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '我的',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 用户资料卡片
            const UserProfile(),
            const SizedBox(height: 24),
            
            // 钱包管理
            _buildSection(
              title: '钱包管理',
              children: [
                _buildMenuItem(
                  icon: Icons.account_balance_wallet,
                  title: '钱包设置',
                  subtitle: '管理钱包连接和设置',
                  onTap: () {
                    _showWalletSettings(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.security,
                  title: '安全设置',
                  subtitle: '私钥管理和安全选项',
                  onTap: () {
                    _showSecuritySettings(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.backup,
                  title: '备份钱包',
                  subtitle: '导出私钥和助记词',
                  onTap: () {
                    _showBackupWallet(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 应用设置
            _buildSection(
              title: '应用设置',
              children: [
                _buildMenuItem(
                  icon: Icons.notifications,
                  title: '通知设置',
                  subtitle: '管理推送通知',
                  onTap: () {
                    _showNotificationSettings(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.language,
                  title: '语言设置',
                  subtitle: '选择应用语言',
                  onTap: () {
                    _showLanguageSettings(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.dark_mode,
                  title: '主题设置',
                  subtitle: '选择深色或浅色主题',
                  onTap: () {
                    _showThemeSettings(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 帮助与支持
            _buildSection(
              title: '帮助与支持',
              children: [
                _buildMenuItem(
                  icon: Icons.help,
                  title: '帮助中心',
                  subtitle: '常见问题和使用指南',
                  onTap: () {
                    _showHelpCenter(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.feedback,
                  title: '意见反馈',
                  subtitle: '向我们提供建议',
                  onTap: () {
                    _showFeedback(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info,
                  title: '关于我们',
                  subtitle: '应用版本和开发者信息',
                  onTap: () {
                    _showAbout(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 退出登录
            Consumer<SupabaseStateManager>(
              builder: (context, supabaseState, child) {
                return _buildSection(
                  title: '账户',
                  children: [
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: '退出登录',
                      subtitle: '安全退出当前账户',
                      onTap: () {
                        _showLogoutDialog(context, supabaseState);
                      },
                      isDestructive: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive 
            ? Colors.red 
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // 钱包设置
  void _showWalletSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('钱包设置'),
        content: const Text('钱包设置功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 安全设置
  void _showSecuritySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('安全设置'),
        content: const Text('安全设置功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 备份钱包
  void _showBackupWallet(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('备份钱包'),
        content: const Text('备份钱包功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 通知设置
  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知设置'),
        content: const Text('通知设置功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 语言设置
  void _showLanguageSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('语言设置'),
        content: const Text('语言设置功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 主题设置
  void _showThemeSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('主题设置'),
        content: const Text('主题设置功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 帮助中心
  void _showHelpCenter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('帮助中心'),
        content: const Text('帮助中心功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 意见反馈
  void _showFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('意见反馈'),
        content: const Text('意见反馈功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 关于我们
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于我们'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Web3 Links'),
            SizedBox(height: 8),
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('一个安全的Web3钱包应用'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 设置对话框
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置'),
        content: const Text('设置功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 退出登录对话框
  void _showLogoutDialog(BuildContext context, SupabaseStateManager supabaseState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _logout(context, supabaseState);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  // 退出登录
  Future<void> _logout(BuildContext context, SupabaseStateManager supabaseState) async {
    try {
      // 这里可以添加退出登录的逻辑
      print('用户退出登录');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已退出登录'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('退出登录失败: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('退出登录失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}