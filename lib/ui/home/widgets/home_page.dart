import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3_links/main.dart';
import 'package:web3_links/ui/home/view_models/wallet_view_model.dart';
import 'package:web3_links/core/auth/supabase_state_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    appLogger.info('HomePage initState');
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    
    // 延迟加载钱包数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWalletData();
    });
  }

  void _loadWalletData() {
    final walletViewModel = Provider.of<WalletViewModel>(context, listen: false);
    final supabaseStateManager = Provider.of<SupabaseStateManager>(context, listen: false);
    
    // 初始化钱包ViewModel
    walletViewModel.initialize(supabaseStateManager);
    
    // 初始化钱包服务
    walletViewModel.initializeWallet().then((_) {
      if (walletViewModel.error == null) {
        // 只有在有钱包地址时才加载数据
        if (walletViewModel.hasWallet) {
          _refreshWalletData(walletViewModel);
        }
      }
    });
  }

  Future<void> _refreshData() async {
    final walletViewModel = Provider.of<WalletViewModel>(context, listen: false);
    
    try {
      // 刷新所有数据
      await Future.wait([
        walletViewModel.getBalance(),
        walletViewModel.loadAssets(),
        walletViewModel.loadTransactions(),
      ]);
      
      appLogger.info('数据刷新完成');
    } catch (e) {
      appLogger.error('数据刷新失败: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletViewModel>(
      builder: (context, walletViewModel, child) {
        return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Web3 钱包',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    _showSettingsDialog(context, walletViewModel);
                  },
                ),
                Consumer<WalletViewModel>(
                  builder: (context, walletViewModel, child) {
                    return IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () {
                        // 扫描二维码
                        walletViewModel.scanQRCode();
                      },
                    );
                  },
                ),
              ],
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _refreshData();
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 错误提示
                        Consumer<WalletViewModel>(
                          builder: (context, walletViewModel, child) {
                            if (walletViewModel.error != null) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        walletViewModel.error!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        walletViewModel.clearError();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        
                        // 钱包卡片
                        _buildWalletCard(context, walletViewModel),
                        const SizedBox(height: 24),
                        
                        // 快速操作
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        
                        // 资产列表 - 只在有钱包时显示
                        if (walletViewModel.hasWallet) ...[
                          _buildAssetsList(context, walletViewModel),
                          const SizedBox(height: 24),
                        ],
                        
                        // 最近交易 - 只在有钱包时显示
                        if (walletViewModel.hasWallet) ...[
                          _buildRecentTransactions(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButton: Consumer<WalletViewModel>(
              builder: (context, walletViewModel, child) {
                if (!walletViewModel.hasWallet) {
                  return const SizedBox.shrink();
                }
                return FloatingActionButton.extended(
                  onPressed: () {
                    // 发送交易
                    walletViewModel.sendTransactionAction();
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.send),
                  label: const Text('发送'),
                );
              },
            ),
          );
      },
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletViewModel walletViewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '钱包余额',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        walletViewModel.isBalanceVisible 
                            ? walletViewModel.formattedTotalBalance
                            : '****',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          walletViewModel.isBalanceVisible 
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          walletViewModel.toggleBalanceVisibility();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  walletViewModel.currentNetwork.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '钱包地址',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        walletViewModel.hasWallet 
                            ? walletViewModel.shortAddress
                            : '未设置钱包',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (walletViewModel.hasWallet) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: () {
                            walletViewModel.copyAddress();
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              // 检查是否有钱包地址，如果没有显示创建钱包按钮
              if (!walletViewModel.hasWallet)
                ElevatedButton(
                  onPressed: () {
                    _showCreateWalletDialog(context, walletViewModel);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('创建钱包'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快速操作',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Consumer<WalletViewModel>(
          builder: (context, walletViewModel, child) {
            if (!walletViewModel.hasWallet) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '请先创建或导入钱包',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }
            
            return Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.qr_code,
                    title: '接收',
                    onTap: () {
                      walletViewModel.showQRCode();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.swap_horiz,
                    title: '兑换',
                    onTap: () {
                      walletViewModel.swapTokens();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.history,
                    title: '历史',
                    onTap: () {
                      walletViewModel.viewHistory();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
                      border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsList(BuildContext context, WalletViewModel walletViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '我的资产',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // 查看所有资产
              },
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<WalletViewModel>(
          builder: (context, walletViewModel, child) {
            if (walletViewModel.isLoading && walletViewModel.assets.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (walletViewModel.assets.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '暂无资产数据',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }
            
            return Column(
              children: walletViewModel.assets.map((asset) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAssetItem(
                  context,
                  icon: asset.icon,
                  name: asset.name,
                  symbol: asset.symbol,
                  balance: asset.balance.toString(),
                  value: '\$${asset.value.toStringAsFixed(2)}',
                  change: '${asset.change >= 0 ? '+' : ''}${asset.change.toStringAsFixed(1)}%',
                  isPositive: asset.change >= 0,
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssetItem(
    BuildContext context, {
    required String icon,
    required String name,
    required String symbol,
    required String balance,
    required String value,
    required String change,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Image.asset(
              icon,
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$balance $symbol',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '最近交易',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Consumer<WalletViewModel>(
              builder: (context, walletViewModel, child) {
                return TextButton(
                  onPressed: () {
                    walletViewModel.viewHistory();
                  },
                  child: const Text('查看全部'),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<WalletViewModel>(
          builder: (context, walletViewModel, child) {
            if (walletViewModel.isLoading && walletViewModel.transactions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (walletViewModel.transactions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '暂无交易记录',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }
            
            return Column(
              children: walletViewModel.transactions.map((transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTransactionItem(
                  context,
                  type: transaction.type,
                  amount: transaction.amount,
                  address: transaction.address,
                  time: _formatTime(transaction.time),
                  isOutgoing: transaction.isOutgoing,
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String type,
    required String amount,
    required String address,
    required String time,
    required bool isOutgoing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isOutgoing 
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
              color: isOutgoing ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  address,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isOutgoing ? Colors.red : Colors.green,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发送资产'),
        content: const Text('发送功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showCreateWalletDialog(BuildContext context, WalletViewModel walletViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建钱包'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('选择创建钱包的方式：'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _createNewWallet(context, walletViewModel);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('新建钱包'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showImportWalletDialog(context, walletViewModel);
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('导入钱包'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewWallet(BuildContext context, WalletViewModel walletViewModel) async {
    try {
      final wallet = await walletViewModel.generateNewWallet();
      if (wallet != null) {
        // 导入新创建的钱包
        final address = await walletViewModel.importWallet(wallet['privateKey']!);
        if (address != null) {
          // 重新加载数据
          await _refreshWalletData(walletViewModel);
          
          // 显示成功消息
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('钱包创建成功: ${walletViewModel.shortAddress}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('钱包创建失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImportWalletDialog(BuildContext context, WalletViewModel walletViewModel) {
    final privateKeyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入钱包'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入私钥：'),
            const SizedBox(height: 16),
            TextField(
              controller: privateKeyController,
              decoration: const InputDecoration(
                hintText: '输入私钥（0x开头）',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final privateKey = privateKeyController.text.trim();
              if (privateKey.isNotEmpty) {
                Navigator.of(context).pop();
                await _importWallet(context, walletViewModel, privateKey);
              }
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }

  Future<void> _importWallet(BuildContext context, WalletViewModel walletViewModel, String privateKey) async {
    try {
      final address = await walletViewModel.importWallet(privateKey);
      if (address != null) {
        // 重新加载数据
        await _refreshWalletData(walletViewModel);
        
        // 显示成功消息
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('钱包导入成功: ${walletViewModel.shortAddress}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('钱包导入失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 刷新钱包数据
  Future<void> _refreshWalletData(WalletViewModel walletViewModel) async {
    try {
      // 并行加载所有数据以提高性能
      await Future.wait([
        walletViewModel.getBalance(),
        walletViewModel.loadAssets(),
        walletViewModel.loadTransactions(),
      ]);
      
      appLogger.info('钱包数据刷新完成');
    } catch (e) {
      appLogger.error('钱包数据刷新失败: $e');
    }
  }

  void _showSettingsDialog(BuildContext context, WalletViewModel walletViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (walletViewModel.hasWallet) ...[
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('清除钱包'),
                subtitle: const Text('删除当前钱包，需要重新导入'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _clearWallet(context, walletViewModel);
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('关于'),
              subtitle: const Text('Web3 Links v1.0.0'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearWallet(BuildContext context, WalletViewModel walletViewModel) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('这将删除当前钱包。此操作不可逆，请确保已备份私钥。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await walletViewModel.clearWallet();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('钱包已清除'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('清除钱包失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}