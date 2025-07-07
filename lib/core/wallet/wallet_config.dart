import 'package:flutter_dotenv/flutter_dotenv.dart';

class WalletConfig {
  // 网络配置 - 从环境变量获取
  static Map<String, String> get networks {
    final ethProjectId = dotenv.get('ETH_MAIN_KEY', fallback: 'YOUR_PROJECT_ID');
    return {
      'ethereum': 'https://mainnet.infura.io/v3/$ethProjectId',
      'polygon': dotenv.get('POLYGON_RPC_URL', fallback: 'https://polygon-rpc.com'),
      'bsc': dotenv.get('BSC_RPC_URL', fallback: 'https://bsc-dataseed.binance.org'),
      'goerli': 'https://goerli.infura.io/v3/$ethProjectId',
      'sepolia': 'https://sepolia.infura.io/v3/$ethProjectId',
    };
  }

  // 链ID配置
  static const Map<String, int> chainIds = {
    'ethereum': 1,
    'polygon': 137,
    'bsc': 56,
    'goerli': 5,
    'sepolia': 11155111,
  };

  // 常用代币合约地址
  static const Map<String, Map<String, String>> tokenContracts = {
    'ethereum': {
      'USDT': '0xdAC17F958D2ee523a2206206994597C13D831ec7',
      'USDC': '0xA0b86a33E6441b8C4C8C8C8C8C8C8C8C8C8C8C8',
      'DAI': '0x6B175474E89094C44Da98b954EedeAC495271d0F',
    },
    'polygon': {
      'USDT': '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
      'USDC': '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174',
      'DAI': '0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063',
    },
    'bsc': {
      'USDT': '0x55d398326f99059fF775485246999027B3197955',
      'USDC': '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
      'BUSD': '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56',
    },
  };

  // Gas限制配置
  static const Map<String, int> gasLimits = {
    'eth_transfer': 21000,
    'token_transfer': 65000,
    'contract_interaction': 100000,
  };

  // 默认Gas价格 (Gwei)
  static const Map<String, int> defaultGasPrices = {
    'ethereum': 20,
    'polygon': 30,
    'bsc': 5,
    'goerli': 1,
    'sepolia': 1,
  };

  /// 获取网络RPC URL
  static String getRpcUrl(String network) {
    return networks[network.toLowerCase()] ?? networks['ethereum']!;
  }

  /// 获取链ID
  static int getChainId(String network) {
    return chainIds[network.toLowerCase()] ?? 1;
  }

  /// 获取代币合约地址
  static String? getTokenContract(String network, String symbol) {
    final networkTokens = tokenContracts[network.toLowerCase()];
    return networkTokens?[symbol.toUpperCase()];
  }

  /// 获取Gas限制
  static int getGasLimit(String transactionType) {
    return gasLimits[transactionType] ?? 21000;
  }

  /// 获取默认Gas价格
  static int getDefaultGasPrice(String network) {
    return defaultGasPrices[network.toLowerCase()] ?? 20;
  }
} 