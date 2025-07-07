import 'package:web3dart/web3dart.dart';
import 'package:web3_links/core/wallet/wallet_service.dart';
import 'package:web3_links/core/wallet/wallet_config.dart';
import 'package:web3_links/utils/logger.dart';

class WalletExample {
  static final WalletService _walletService = WalletService();
  static final AppLogger _logger = AppLogger('wallet_example');

  /// 初始化钱包服务示例
  static Future<void> initializeWallet() async {
    try {
      await _walletService.initialize(network: 'ethereum');
      _logger.info('钱包服务初始化成功');
    } catch (e) {
      _logger.error('钱包服务初始化失败: $e');
    }
  }

  /// 生成新钱包示例
  static Future<Map<String, String>?> generateWallet() async {
    try {
      final wallet = await _walletService.generateNewWallet();
      _logger.info('新钱包生成成功: ${wallet['address']}');
      return wallet;
    } catch (e) {
      _logger.error('钱包生成失败: $e');
      return null;
    }
  }

  /// 从私钥导入钱包示例
  static Future<EthereumAddress?> importWallet(String privateKey) async {
    try {
      final address = await _walletService.createWalletFromPrivateKey(privateKey);
      _logger.info('钱包导入成功: ${address.hex}');
      return address;
    } catch (e) {
      _logger.error('钱包导入失败: $e');
      return null;
    }
  }

  /// 获取余额示例
  static Future<void> getBalance() async {
    try {
      final balance = await _walletService.getBalance();
      _logger.info('当前余额: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
    } catch (e) {
      _logger.error('获取余额失败: $e');
    }
  }

  /// 发送交易示例
  static Future<String?> sendTransaction({
    required String toAddress,
    required double amount,
  }) async {
    try {
      // 验证地址格式
      if (!_walletService.isValidAddress(toAddress)) {
        throw Exception('无效的地址格式');
      }

      final to = EthereumAddress.fromHex(toAddress);
      final etherAmount = EtherAmount.fromInt(EtherUnit.ether, (amount * 1e18).round());

      final hash = await _walletService.sendTransaction(
        to: to,
        amount: etherAmount,
      );

      _logger.info('交易发送成功: $hash');
      return hash;
    } catch (e) {
      _logger.error('交易发送失败: $e');
      return null;
    }
  }

  /// 获取代币余额示例
  static Future<BigInt?> getTokenBalance({
    required String tokenSymbol,
    required String walletAddress,
  }) async {
    try {
      final currentNetwork = _walletService.currentNetwork;
      final tokenContract = WalletConfig.getTokenContract(currentNetwork, tokenSymbol);
      
      if (tokenContract == null) {
        throw Exception('未找到代币合约地址');
      }

      final contractAddress = EthereumAddress.fromHex(tokenContract);
      final walletAddr = EthereumAddress.fromHex(walletAddress);

      final balance = await _walletService.getTokenBalance(
        tokenContract: contractAddress,
        walletAddress: walletAddr,
      );

      _logger.info('$tokenSymbol 余额: $balance');
      return balance;
    } catch (e) {
      _logger.error('获取代币余额失败: $e');
      return null;
    }
  }

  /// 发送代币示例
  static Future<String?> sendToken({
    required String tokenSymbol,
    required String toAddress,
    required BigInt amount,
  }) async {
    try {
      final currentNetwork = _walletService.currentNetwork;
      final tokenContract = WalletConfig.getTokenContract(currentNetwork, tokenSymbol);
      
      if (tokenContract == null) {
        throw Exception('未找到代币合约地址');
      }

      final contractAddress = EthereumAddress.fromHex(tokenContract);
      final to = EthereumAddress.fromHex(toAddress);

      final hash = await _walletService.sendToken(
        tokenContract: contractAddress,
        to: to,
        amount: amount,
      );

      _logger.info('代币发送成功: $hash');
      return hash;
    } catch (e) {
      _logger.error('代币发送失败: $e');
      return null;
    }
  }

  /// 切换网络示例
  static Future<void> switchNetwork(String network) async {
    try {
      await _walletService.switchNetwork(network);
      _logger.info('网络切换成功: $network');
    } catch (e) {
      _logger.error('网络切换失败: $e');
    }
  }

  /// 获取Gas价格示例
  static Future<void> getGasPrice() async {
    try {
      final gasPrice = await _walletService.getGasPrice();
      _logger.info('当前Gas价格: ${gasPrice.getValueInUnit(EtherUnit.gwei)} Gwei');
    } catch (e) {
      _logger.error('获取Gas价格失败: $e');
    }
  }

  /// 估算Gas费用示例
  static Future<BigInt?> estimateGas({
    required String toAddress,
    required double amount,
  }) async {
    try {
      final to = EthereumAddress.fromHex(toAddress);
      final etherAmount = EtherAmount.fromInt(EtherUnit.ether, (amount * 1e18).round());

      final gas = await _walletService.estimateGas(
        to: to,
        amount: etherAmount,
      );

      _logger.info('估算Gas费用: $gas');
      return gas;
    } catch (e) {
      _logger.error('估算Gas失败: $e');
      return null;
    }
  }

  /// 格式化地址示例
  static String formatAddress(String address) {
    return _walletService.formatAddress(address);
  }

  /// 验证地址示例
  static bool validateAddress(String address) {
    return _walletService.isValidAddress(address);
  }

  /// 完整的使用示例
  static Future<void> completeExample() async {
    _logger.info('开始钱包使用示例');

    // 1. 初始化钱包服务
    await initializeWallet();

    // 2. 生成新钱包
    final wallet = await generateWallet();
    if (wallet != null) {
      _logger.info('钱包地址: ${wallet['address']}');
      _logger.info('私钥: ${wallet['privateKey']}');

      // 3. 导入钱包
      final address = await importWallet(wallet['privateKey']!);
      if (address != null) {
        // 4. 获取余额
        await getBalance();

        // 5. 获取Gas价格
        await getGasPrice();

        // 6. 验证地址格式
        final isValid = validateAddress(address.hex);
        _logger.info('地址格式验证: $isValid');

        // 7. 格式化地址显示
        final formatted = formatAddress(address.hex);
        _logger.info('格式化地址: $formatted');
      }
    }

    _logger.info('钱包使用示例完成');
  }
} 