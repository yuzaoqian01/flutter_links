import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web3_links/utils/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3_links/utils/app_storage.dart';
import 'package:web3_links/constants/storage_keys.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  Web3Client? _client;
  Credentials? _credentials;
  EthereumAddress? _address;
  String? _privateKey;
  
  // 网络配置 - 从环境变量获取
  String get _ethereumRpcUrl {
    final projectId = dotenv.get('ETH_MAIN_KEY', fallback: 'YOUR_PROJECT_ID');
    return 'https://mainnet.infura.io/v3/$projectId';
  }
  
  String get _polygonRpcUrl => dotenv.get('POLYGON_RPC_URL', fallback: 'https://polygon-rpc.com');
  String get _bscRpcUrl => dotenv.get('BSC_RPC_URL', fallback: 'https://bsc-dataseed.binance.org');
  
  // 当前网络
  String _currentNetwork = 'ethereum';
  
  // 获取当前网络
  String get currentNetwork => _currentNetwork;
  
  // 获取当前地址
  EthereumAddress? get currentAddress => _address;
  
  // 获取客户端
  Web3Client? get client => _client;

  /// 初始化钱包服务
  Future<void> initialize({String network = 'ethereum'}) async {
    try {
      _currentNetwork = network;
      String rpcUrl = _getRpcUrl(network);
      
      AppLogger('wallet').info('RPC URL: $rpcUrl');
      
      _client = Web3Client(rpcUrl, http.Client());
      
      // 尝试恢复钱包状态
      await _restoreWalletState();
      
      AppLogger('wallet').info('钱包服务初始化成功: $network');
    } catch (e) {
      AppLogger('wallet').error('钱包服务初始化失败: $e');
      rethrow;
    }
  }

  /// 恢复钱包状态
  Future<void> _restoreWalletState() async {
    try {
      final savedPrivateKey = await AppStorage.getString(StorageKeys.walletPrivateKey);
      if (savedPrivateKey != null && savedPrivateKey.isNotEmpty) {
        await createWalletFromPrivateKey(savedPrivateKey);
        AppLogger('wallet').info('钱包状态恢复成功');
      }
    } catch (e) {
      AppLogger('wallet').error('钱包状态恢复失败: $e');
    }
  }

  /// 保存钱包状态
  Future<void> _saveWalletState() async {
    if (_privateKey != null) {
      await AppStorage.setString(StorageKeys.walletPrivateKey, _privateKey!);
      AppLogger('wallet').info('钱包状态保存成功');
    }
  }

  /// 清除钱包状态
  Future<void> _clearWalletState() async {
    await AppStorage.remove(StorageKeys.walletPrivateKey);
    _privateKey = null;
    _credentials = null;
    _address = null;
    AppLogger('wallet').info('钱包状态清除成功');
  }

  /// 清除钱包
  Future<void> clearWallet() async {
    await _clearWalletState();
    AppLogger('wallet').info('钱包已清除');
  }

  /// 获取RPC URL
  String _getRpcUrl(String network) {
    switch (network.toLowerCase()) {
      case 'ethereum':
        return _ethereumRpcUrl;
      case 'polygon':
        return _polygonRpcUrl;
      case 'bsc':
        return _bscRpcUrl;
      default:
        return _ethereumRpcUrl;
    }
  }

  /// 从私钥创建钱包
  Future<EthereumAddress> createWalletFromPrivateKey(String privateKey) async {
    try {
      _privateKey = privateKey;
      _credentials = EthPrivateKey.fromHex(privateKey);
      _address = _credentials!.address;
      
      // 保存钱包状态
      await _saveWalletState();
      
      AppLogger('wallet').info('钱包创建成功: ${_address!.hex}');
      return _address!;
    } catch (e) {
      AppLogger('wallet').error('钱包创建失败: $e');
      rethrow;
    }
  }

  /// 生成新钱包
  Future<Map<String, String>> generateNewWallet() async {
    try {
      final credentials = EthPrivateKey.createRandom(Random.secure());
      final address = credentials.address;
      final privateKey = credentials.privateKey;
      
      final wallet = {
        'address': address.hex,
        'privateKey': privateKey.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(),
      };
      
      AppLogger('wallet').info('新钱包生成成功: ${address.hex}');
      return wallet;
    } catch (e) {
      AppLogger('wallet').error('钱包生成失败: $e');
      rethrow;
    }
  }

  /// 检查是否有钱包地址
  bool get hasWallet => _address != null;

  /// 获取钱包地址字符串
  String? get walletAddress => _address?.hex;

  /// 获取余额
  Future<EtherAmount> getBalance([EthereumAddress? address]) async {
    try {
      if (_client == null) {
        throw Exception('钱包服务未初始化');
      }
      
      final targetAddress = address ?? _address;
      if (targetAddress == null) {
        throw Exception('钱包地址未设置');
      }
      
      final balance = await _client!.getBalance(targetAddress);
      AppLogger('wallet').info('余额查询成功: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
      return balance;
    } catch (e) {
      AppLogger('wallet').error('余额查询失败: $e');
      rethrow;
    }
  }

  /// 发送交易
  Future<String> sendTransaction({
    required EthereumAddress to,
    required EtherAmount amount,
    EtherAmount? gasPrice,
    int? gasLimit,
  }) async {
    try {
      if (_client == null || _credentials == null) {
        throw Exception('钱包服务未初始化或未设置私钥');
      }
      
      final transaction = Transaction(
        to: to,
        value: amount,
        gasPrice: gasPrice ?? await _client!.getGasPrice(),
        maxGas: gasLimit ?? 21000,
      );
      
      final hash = await _client!.sendTransaction(
        _credentials!,
        transaction,
        chainId: _getChainId(),
      );
      
      AppLogger('wallet').info('交易发送成功: $hash');
      return hash;
    } catch (e) {
      AppLogger('wallet').error('交易发送失败: $e');
      rethrow;
    }
  }

  /// 获取交易历史
  Future<List<TransactionReceipt>> getTransactionHistory([int? limit]) async {
    try {
      if (_client == null || _address == null) {
        throw Exception('钱包服务未初始化或地址未设置');
      }
      
      // 这里需要根据具体的区块链API来获取交易历史
      // 这是一个简化的实现
      AppLogger('wallet').info('获取交易历史');
      return [];
    } catch (e) {
      AppLogger('wallet').error('获取交易历史失败: $e');
      rethrow;
    }
  }

  /// 获取代币余额
  Future<BigInt> getTokenBalance({
    required EthereumAddress tokenContract,
    required EthereumAddress walletAddress,
  }) async {
    try {
      if (_client == null) {
        throw Exception('钱包服务未初始化');
      }
      
      final contract = DeployedContract(
        ContractAbi.fromJson(
          jsonEncode([
            {
              "constant": true,
              "inputs": [{"name": "_owner", "type": "address"}],
              "name": "balanceOf",
              "outputs": [{"name": "", "type": "uint256"}],
              "type": "function"
            }
          ]),
          'ERC20',
        ),
        tokenContract,
      );
      
      final balanceFunction = contract.function('balanceOf');
      final result = await _client!.call(
        contract: contract,
        function: balanceFunction,
        params: [walletAddress],
      );
      
      final balance = result.first as BigInt;
      AppLogger('wallet').info('代币余额查询成功: $balance');
      return balance;
    } catch (e) {
      AppLogger('wallet').error('代币余额查询失败: $e');
      rethrow;
    }
  }

  /// 发送代币
  Future<String> sendToken({
    required EthereumAddress tokenContract,
    required EthereumAddress to,
    required BigInt amount,
    EtherAmount? gasPrice,
    int? gasLimit,
  }) async {
    try {
      if (_client == null || _credentials == null) {
        throw Exception('钱包服务未初始化或未设置私钥');
      }
      
      final contract = DeployedContract(
        ContractAbi.fromJson(
          jsonEncode([
            {
              "constant": false,
              "inputs": [
                {"name": "_to", "type": "address"},
                {"name": "_value", "type": "uint256"}
              ],
              "name": "transfer",
              "outputs": [{"name": "", "type": "bool"}],
              "type": "function"
            }
          ]),
          'ERC20',
        ),
        tokenContract,
      );
      
      final transferFunction = contract.function('transfer');
      final data = transferFunction.encodeCall([to, amount]);
      
      final transaction = Transaction(
        to: tokenContract,
        data: data,
        gasPrice: gasPrice ?? await _client!.getGasPrice(),
        maxGas: gasLimit ?? 65000,
      );
      
      final hash = await _client!.sendTransaction(
        _credentials!,
        transaction,
        chainId: _getChainId(),
      );
      
      AppLogger('wallet').info('代币发送成功: $hash');
      return hash;
    } catch (e) {
      AppLogger('wallet').error('代币发送失败: $e');
      rethrow;
    }
  }

  /// 获取网络ID
  int _getChainId() {
    switch (_currentNetwork.toLowerCase()) {
      case 'ethereum':
        return 1;
      case 'polygon':
        return 137;
      case 'bsc':
        return 56;
      default:
        return 1;
    }
  }

  /// 切换网络
  Future<void> switchNetwork(String network) async {
    try {
      await initialize(network: network);
      AppLogger('wallet').info('网络切换成功: $network');
    } catch (e) {
      AppLogger('wallet').error('网络切换失败: $e');
      rethrow;
    }
  }

  /// 获取Gas价格
  Future<EtherAmount> getGasPrice() async {
    try {
      if (_client == null) {
        throw Exception('钱包服务未初始化');
      }
      
      final gasPrice = await _client!.getGasPrice();
      AppLogger('wallet').info('Gas价格查询成功: ${gasPrice.getInWei} Wei');
      return gasPrice;
    } catch (e) {
      AppLogger('wallet').error('Gas价格查询失败: $e');
      rethrow;
    }
  }

  /// 估算Gas费用
  Future<BigInt> estimateGas({
    required EthereumAddress to,
    required EtherAmount amount,
    Uint8List? data,
  }) async {
    try {
      if (_client == null) {
        throw Exception('钱包服务未初始化');
      }
      
      final gas = await _client!.estimateGas(
        sender: _address,
        to: to,
        value: amount,
        data: data,
      );
      
      AppLogger('wallet').info('Gas估算成功: $gas');
      return gas;
    } catch (e) {
      AppLogger('wallet').error('Gas估算失败: $e');
      rethrow;
    }
  }

  /// 验证地址格式
  bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 格式化地址显示
  String formatAddress(String address, {int prefixLength = 6, int suffixLength = 4}) {
    if (address.length <= prefixLength + suffixLength) {
      return address;
    }
    return '${address.substring(0, prefixLength)}...${address.substring(address.length - suffixLength)}';
  }

  /// 清理资源
  void dispose() {
    _client?.dispose();
    _client = null;
    _credentials = null;
    _address = null;
    _privateKey = null;
    AppLogger('wallet').info('钱包服务已清理');
  }
} 