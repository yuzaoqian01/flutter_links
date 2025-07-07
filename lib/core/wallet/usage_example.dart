import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3_links/core/wallet/wallet_service.dart';
import 'package:web3_links/core/wallet/wallet_config.dart';
import 'package:web3_links/utils/logger.dart';

/// 钱包使用示例页面
class WalletUsageExample extends StatefulWidget {
  const WalletUsageExample({super.key});

  @override
  State<WalletUsageExample> createState() => _WalletUsageExampleState();
}

class _WalletUsageExampleState extends State<WalletUsageExample> {
  final WalletService _walletService = WalletService();
  final AppLogger _logger = AppLogger('wallet_usage');
  
  String _status = '未初始化';
  String _walletAddress = '';
  String _balance = '';
  String _gasPrice = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeWallet();
  }

  /// 初始化钱包
  Future<void> _initializeWallet() async {
    setState(() {
      _isLoading = true;
      _status = '正在初始化...';
    });

    try {
      await _walletService.initialize(network: 'ethereum');
      setState(() {
        _status = '钱包服务初始化成功';
        _isLoading = false;
      });
      _logger.info('钱包服务初始化成功');
    } catch (e) {
      setState(() {
        _status = '初始化失败: $e';
        _isLoading = false;
      });
      _logger.error('钱包服务初始化失败: $e');
    }
  }

  /// 生成新钱包
  Future<void> _generateWallet() async {
    setState(() {
      _isLoading = true;
      _status = '正在生成钱包...';
    });

    try {
      final wallet = await _walletService.generateNewWallet();
      setState(() {
        _walletAddress = wallet['address'] ?? '';
        _status = '新钱包生成成功';
        _isLoading = false;
      });
      _logger.info('新钱包生成成功: ${wallet['address']}');
    } catch (e) {
      setState(() {
        _status = '钱包生成失败: $e';
        _isLoading = false;
      });
      _logger.error('钱包生成失败: $e');
    }
  }

  /// 导入钱包
  Future<void> _importWallet(String privateKey) async {
    setState(() {
      _isLoading = true;
      _status = '正在导入钱包...';
    });

    try {
      final address = await _walletService.createWalletFromPrivateKey(privateKey);
      setState(() {
        _walletAddress = address.hex;
        _status = '钱包导入成功';
        _isLoading = false;
      });
      _logger.info('钱包导入成功: ${address.hex}');
    } catch (e) {
      setState(() {
        _status = '钱包导入失败: $e';
        _isLoading = false;
      });
      _logger.error('钱包导入失败: $e');
    }
  }

  /// 获取余额
  Future<void> _getBalance() async {
    if (_walletService.currentAddress == null) {
      setState(() {
        _status = '请先生成或导入钱包';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '正在获取余额...';
    });

    try {
      final balance = await _walletService.getBalance();
      setState(() {
        _balance = '${balance.getInEther} ETH';
        _status = '余额获取成功';
        _isLoading = false;
      });
      _logger.info('余额获取成功: ${balance.getInEther} ETH');
    } catch (e) {
      setState(() {
        _status = '余额获取失败: $e';
        _isLoading = false;
      });
      _logger.error('余额获取失败: $e');
    }
  }

  /// 获取Gas价格
  Future<void> _getGasPrice() async {
    setState(() {
      _isLoading = true;
      _status = '正在获取Gas价格...';
    });

    try {
      final gasPrice = await _walletService.getGasPrice();
      setState(() {
        _gasPrice = '${gasPrice.getInWei} Wei';
        _status = 'Gas价格获取成功';
        _isLoading = false;
      });
      _logger.info('Gas价格获取成功: ${gasPrice.getInWei} Wei');
    } catch (e) {
      setState(() {
        _status = 'Gas价格获取失败: $e';
        _isLoading = false;
      });
      _logger.error('Gas价格获取失败: $e');
    }
  }

  /// 切换网络
  Future<void> _switchNetwork(String network) async {
    setState(() {
      _isLoading = true;
      _status = '正在切换网络...';
    });

    try {
      await _walletService.switchNetwork(network);
      setState(() {
        _status = '网络切换成功: $network';
        _isLoading = false;
      });
      _logger.info('网络切换成功: $network');
    } catch (e) {
      setState(() {
        _status = '网络切换失败: $e';
        _isLoading = false;
      });
      _logger.error('网络切换失败: $e');
    }
  }

  /// 发送测试交易
  Future<void> _sendTestTransaction() async {
    if (_walletService.currentAddress == null) {
      setState(() {
        _status = '请先生成或导入钱包';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '正在发送测试交易...';
    });

    try {
      // 这是一个测试地址，实际使用时需要替换为真实地址
      final toAddress = EthereumAddress.fromHex('0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6');
      final amount = 0.001;
      final etherAmount = EtherAmount.inWei(BigInt.from((amount * 1e18).round()));

      final hash = await _walletService.sendTransaction(
        to: toAddress,
        amount: etherAmount,
      );

      setState(() {
        _status = '测试交易发送成功: $hash';
        _isLoading = false;
      });
      _logger.info('测试交易发送成功: $hash');
    } catch (e) {
      setState(() {
        _status = '测试交易发送失败: $e';
        _isLoading = false;
      });
      _logger.error('测试交易发送失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('钱包使用示例'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '状态: $_status',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (_isLoading) 
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 钱包地址
            if (_walletAddress.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '钱包地址:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _walletAddress,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),

            // 余额显示
            if (_balance.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '余额:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_balance),
                    ],
                  ),
                ),
              ),

            // Gas价格显示
            if (_gasPrice.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gas价格:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_gasPrice),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 操作按钮
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildActionButton(
                      '生成新钱包',
                      Icons.add,
                      _generateWallet,
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      '获取余额',
                      Icons.account_balance_wallet,
                      _getBalance,
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      '获取Gas价格',
                      Icons.speed,
                      _getGasPrice,
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      '切换到Polygon',
                      Icons.swap_horiz,
                      () => _switchNetwork('polygon'),
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      '切换到BSC',
                      Icons.swap_horiz,
                      () => _switchNetwork('bsc'),
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      '发送测试交易',
                      Icons.send,
                      _sendTestTransaction,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _walletService.dispose();
    super.dispose();
  }
} 