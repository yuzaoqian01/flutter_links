import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3_links/core/wallet/wallet_service.dart';
import 'package:web3_links/data/models/wallet_info.dart';
import 'package:web3_links/utils/logger.dart';
import 'package:web3_links/core/auth/supabase_state_manager.dart';

class Asset {
  final String name;
  final String symbol;
  final double balance;
  final double value;
  final double change;
  final String icon;

  Asset({
    required this.name,
    required this.symbol,
    required this.balance,
    required this.value,
    required this.change,
    required this.icon,
  });
}

class Transaction {
  final String type;
  final String amount;
  final String address;
  final DateTime time;
  final bool isOutgoing;

  Transaction({
    required this.type,
    required this.amount,
    required this.address,
    required this.time,
    required this.isOutgoing,
  });
}

class WalletViewModel extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  final WalletInfo _walletInfo = WalletInfo.empty();
  bool _isLoading = false;
  String? _error;
  bool _isBalanceVisible = true;
  String _currentNetwork = 'ethereum';
  SupabaseStateManager? _supabaseStateManager;
  
  // 资产数据
  final List<Asset> _assets = [];

  // 交易数据
  final List<Transaction> _transactions = [];

  WalletInfo get walletInfo => _walletInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isBalanceVisible => _isBalanceVisible;
  List<Asset> get assets => _assets;
  List<Transaction> get transactions => _transactions;
  String get currentNetwork => _currentNetwork;

  double get totalBalance {
    if (_assets.isEmpty) {
      return 0.0;
    }
    return _assets.fold(0.0, (sum, asset) => sum + asset.value);
  }

  String get formattedTotalBalance {
    return '\$${totalBalance.toStringAsFixed(2)}';
  }

  String get shortAddress {
    if (_walletService.currentAddress != null) {
      return _walletService.formatAddress(_walletService.currentAddress!.hex);
    }
    return '未设置钱包';
  }

  /// 检查是否有钱包
  bool get hasWallet => _walletService.hasWallet;

  /// 获取完整钱包地址
  String? get walletAddress => _walletService.walletAddress;

  /// 初始化钱包ViewModel
  void initialize(SupabaseStateManager? supabaseStateManager) {
    _supabaseStateManager = supabaseStateManager;
    AppLogger('wallet_vm').warning('钱包ViewModel初始化完成');
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 初始化钱包服务
  Future<void> initializeWallet() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _walletService.initialize(network: _currentNetwork);
      AppLogger('wallet_vm').info('钱包服务初始化成功');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger('wallet_vm').error('钱包服务初始化失败: $e');
      notifyListeners();
    }
  }

  /// 生成新钱包
  Future<Map<String, String>?> generateNewWallet() async {
    try {
      _isLoading = true;
      notifyListeners();

      final wallet = await _walletService.generateNewWallet();
      
      _isLoading = false;
      notifyListeners();
      return wallet;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger('wallet_vm').error('钱包生成失败: $e');
      notifyListeners();
      return null;
    }
  }

  /// 导入钱包
  Future<EthereumAddress?> importWallet(String privateKey) async {
    try {
      _isLoading = true;
      notifyListeners();

      final address = await _walletService.createWalletFromPrivateKey(privateKey);
      
      _isLoading = false;
      notifyListeners();
      
      // 导入成功后立即通知UI更新
      AppLogger('wallet_vm').info('钱包导入成功，地址: ${address.hex}');
      return address;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger('wallet_vm').error('钱包导入失败: $e');
      notifyListeners();
      return null;
    }
  }

  /// 清除钱包
  Future<void> clearWallet() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _walletService.clearWallet();
      
      _isLoading = false;
      notifyListeners();
      
      AppLogger('wallet_vm').info('钱包清除成功');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger('wallet_vm').error('钱包清除失败: $e');
      notifyListeners();
    }
  }

  /// 获取余额
  Future<void> getBalance() async {
    try {
      if (!hasWallet) {
        AppLogger('wallet_vm').warning('没有钱包地址，跳过余额查询');
        return;
      }

      _isLoading = true;
      notifyListeners();

      final balance = await _walletService.getBalance();
      AppLogger('wallet_vm').info('余额查询成功: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger('wallet_vm').error('余额查询失败: $e');
      notifyListeners();
    }
  }

  /// 加载资产数据
  Future<void> loadAssets() async {
    try {
      if (!hasWallet) {
        AppLogger('wallet_vm').warning('没有钱包地址，跳过资产加载');
        return;
      }

      _isLoading = true;
      notifyListeners();

      // 获取ETH余额
      final ethBalance = await _walletService.getBalance();
      final ethValue = ethBalance.getValueInUnit(EtherUnit.ether).toDouble();
      
      // 更新资产列表
      _assets.clear();
      _assets.add(Asset(
        name: 'Ethereum',
        symbol: 'ETH',
        balance: ethValue,
        value: ethValue * _getCurrentEthPrice(),
        change: _getRandomChange(),
        icon: 'assets/images/ic_launcher.png',
      ));

      // 加载代币余额（如果有的话）
      await _loadTokenBalances();
      
      _isLoading = false;
      notifyListeners();
      AppLogger('wallet_vm').info('资产数据加载完成');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger('wallet_vm').error('资产数据加载失败: $e');
      notifyListeners();
    }
  }

  /// 加载代币余额
  Future<void> _loadTokenBalances() async {
    try {
      // 这里可以添加加载USDC、DAI等代币余额的逻辑
      // 暂时不添加模拟数据
      AppLogger('wallet_vm').info('代币余额加载完成（暂无代币）');
    } catch (e) {
      AppLogger('wallet_vm').error('代币余额加载失败: $e');
    }
  }

  /// 加载交易历史
  Future<void> loadTransactions() async {
    try {
      if (!hasWallet) {
        AppLogger('wallet_vm').warning('没有钱包地址，跳过交易历史加载');
        return;
      }

      _isLoading = true;
      notifyListeners();

      // 获取交易历史
      final transactions = await _walletService.getTransactionHistory();
      
      // 更新交易列表
      _transactions.clear();
      for (final tx in transactions) {
        _transactions.add(Transaction(
          type: '成功', // 简化处理，暂时都显示为成功
          amount: '${tx.gasUsed} ETH',
          address: _walletService.formatAddress(tx.transactionHash.toString()),
          time: DateTime.now().subtract(const Duration(hours: 1)),
          isOutgoing: true,
        ));
      }

      // 如果没有交易历史，不添加模拟数据
      if (_transactions.isEmpty) {
        AppLogger('wallet_vm').info('暂无交易历史');
      }
      
      _isLoading = false;
      notifyListeners();
      AppLogger('wallet_vm').info('交易历史加载完成');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger('wallet_vm').error('交易历史加载失败: $e');
      notifyListeners();
    }
  }

  /// 获取当前ETH价格
  double _getCurrentEthPrice() {
    // 这里可以接入真实的ETH价格API
    return 1800.0; // 使用更接近当前市场的价格
  }

  /// 获取随机变化率
  double _getRandomChange() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    return (random - 50) / 10.0; // -5.0 到 5.0 之间的随机数
  }

  /// 发送交易
  Future<String?> sendTransaction({
    required String toAddress,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (!_walletService.isValidAddress(toAddress)) {
        throw Exception('无效的地址格式');
      }

      final to = EthereumAddress.fromHex(toAddress);
      final etherAmount = EtherAmount.fromInt(EtherUnit.ether, (amount * 1e18).round());

      final hash = await _walletService.sendTransaction(
        to: to,
        amount: etherAmount,
      );

      AppLogger('wallet_vm').info('交易发送成功: $hash');
      
      _isLoading = false;
      notifyListeners();
      return hash;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger('wallet_vm').error('交易发送失败: $e');
      notifyListeners();
      return null;
    }
  }

  /// 切换网络
  Future<void> switchNetwork(String network) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _walletService.switchNetwork(network);
      _currentNetwork = network;
      
      AppLogger('wallet_vm').info('网络切换成功: $network');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger('wallet_vm').error('网络切换失败: $e');
      notifyListeners();
    }
  }

  /// 获取Gas价格
  Future<void> getGasPrice() async {
    try {
      final gasPrice = await _walletService.getGasPrice();
      AppLogger('wallet_vm').info('Gas价格: ${gasPrice.getValueInUnit(EtherUnit.wei)} Wei');
    } catch (e) {
      AppLogger('wallet_vm').error('获取Gas价格失败: $e');
    }
  }

  /// 复制地址
  Future<void> copyAddress() async {
    if (_walletService.currentAddress != null) {
      try {
        await Clipboard.setData(ClipboardData(text: _walletService.currentAddress!.hex));
        AppLogger('wallet_vm').info('地址已复制: ${_walletService.currentAddress!.hex}');
      } catch (e) {
        AppLogger('wallet_vm').error('复制地址失败: $e');
      }
    }
  }

  /// 显示二维码
  Future<void> showQRCode() async {
    if (_walletService.currentAddress != null) {
      AppLogger('wallet_vm').info('显示接收二维码: ${_walletService.currentAddress!.hex}');
    }
  }

  /// 扫描二维码
  Future<void> scanQRCode() async {
    AppLogger('wallet_vm').info('扫描二维码功能');
  }

  /// 兑换代币
  Future<void> swapTokens() async {
    AppLogger('wallet_vm').info('兑换代币功能');
    // 这里可以添加导航到兑换页面的逻辑
    // 暂时不调用 notifyListeners() 避免不必要的重建
  }

  /// 查看交易历史
  Future<void> viewHistory() async {
    AppLogger('wallet_vm').info('查看交易历史');
    // 这里可以添加导航到交易历史页面的逻辑
    // 暂时不调用 notifyListeners() 避免不必要的重建
  }

  /// 发送交易
  Future<void> sendTransactionAction() async {
    AppLogger('wallet_vm').info('发送交易功能');
  }

  /// 清理资源
  @override
  void dispose() {
    _walletService.dispose();
    super.dispose();
  }
} 