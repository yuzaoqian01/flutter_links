# Web3 钱包服务库

这是一个基于 `web3dart` 的通用钱包操作库，提供了完整的 Web3 钱包功能。

## 功能特性

### 🚀 核心功能
- ✅ 钱包创建和导入
- ✅ 多网络支持 (Ethereum, Polygon, BSC)
- ✅ 余额查询
- ✅ 交易发送
- ✅ 代币操作 (ERC20)
- ✅ Gas 估算和价格查询
- ✅ 地址验证和格式化

### 🔧 支持的网络
- **Ethereum Mainnet** - 以太坊主网
- **Polygon** - Polygon 网络
- **BSC** - 币安智能链
- **Goerli** - 以太坊测试网
- **Sepolia** - 以太坊测试网

## 快速开始

### 1. 初始化钱包服务

```dart
import 'package:web3_links/core/wallet/wallet_service.dart';

final walletService = WalletService();

// 初始化以太坊网络
await walletService.initialize(network: 'ethereum');
```

### 2. 创建新钱包

```dart
// 生成新钱包
final wallet = await walletService.generateNewWallet();
print('地址: ${wallet['address']}');
print('私钥: ${wallet['privateKey']}');
```

### 3. 导入现有钱包

```dart
// 从私钥导入钱包
final address = await walletService.createWalletFromPrivateKey(privateKey);
print('钱包地址: ${address.hex}');
```

### 4. 查询余额

```dart
// 获取 ETH 余额
final balance = await walletService.getBalance();
print('余额: ${balance.getInEther} ETH');
```

### 5. 发送交易

```dart
// 发送 ETH
final toAddress = EthereumAddress.fromHex('0x...');
final amount = EtherAmount.fromWei(BigInt.from(0.1 * 1e18));

final hash = await walletService.sendTransaction(
  to: toAddress,
  amount: amount,
);
print('交易哈希: $hash');
```

### 6. 代币操作

```dart
// 获取代币余额
final tokenContract = EthereumAddress.fromHex('0x...'); // USDT 合约地址
final balance = await walletService.getTokenBalance(
  tokenContract: tokenContract,
  walletAddress: walletAddress,
);

// 发送代币
final hash = await walletService.sendToken(
  tokenContract: tokenContract,
  to: toAddress,
  amount: BigInt.from(100 * 1e6), // 100 USDT
);
```

### 7. 网络切换

```dart
// 切换到 Polygon 网络
await walletService.switchNetwork('polygon');
```

### 8. Gas 操作

```dart
// 获取 Gas 价格
final gasPrice = await walletService.getGasPrice();
print('Gas 价格: ${gasPrice.getInWei} Wei');

// 估算 Gas 费用
final gas = await walletService.estimateGas(
  to: toAddress,
  amount: etherAmount,
);
print('估算 Gas: $gas');
```

## 配置文件

使用 `WalletConfig` 类来管理网络配置：

```dart
import 'package:web3_links/core/wallet/wallet_config.dart';

// 获取网络 RPC URL
final rpcUrl = WalletConfig.getRpcUrl('ethereum');

// 获取链 ID
final chainId = WalletConfig.getChainId('ethereum');

// 获取代币合约地址
final usdtContract = WalletConfig.getTokenContract('ethereum', 'USDT');
```

## 在 ViewModel 中使用

```dart
class WalletViewModel extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  
  Future<void> initializeWallet() async {
    await _walletService.initialize(network: 'ethereum');
  }
  
  Future<String?> sendTransaction(String toAddress, double amount) async {
    final to = EthereumAddress.fromHex(toAddress);
    final etherAmount = EtherAmount.fromWei(BigInt.from(amount * 1e18));
    
    return await _walletService.sendTransaction(
      to: to,
      amount: etherAmount,
    );
  }
}
```

## 错误处理

所有方法都包含完整的错误处理：

```dart
try {
  final balance = await walletService.getBalance();
  print('余额: ${balance.getInEther} ETH');
} catch (e) {
  print('获取余额失败: $e');
}
```

## 安全注意事项

1. **私钥安全**: 永远不要在客户端存储私钥，建议使用硬件钱包或安全的密钥管理
2. **网络配置**: 在生产环境中使用可靠的 RPC 节点
3. **Gas 费用**: 始终验证 Gas 费用，避免交易失败
4. **地址验证**: 发送交易前验证地址格式

## 配置说明

### 环境变量

在 `.env` 文件中配置 RPC URL：

```env
ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
POLYGON_RPC_URL=https://polygon-rpc.com
BSC_RPC_URL=https://bsc-dataseed.binance.org
```

### 网络配置

修改 `WalletConfig` 中的网络配置：

```dart
static const Map<String, String> networks = {
  'ethereum': 'YOUR_ETHEREUM_RPC_URL',
  'polygon': 'YOUR_POLYGON_RPC_URL',
  'bsc': 'YOUR_BSC_RPC_URL',
};
```

## 示例代码

查看 `wallet_example.dart` 文件获取完整的使用示例。

## 依赖项

确保在 `pubspec.yaml` 中包含以下依赖：

```yaml
dependencies:
  web3dart: ^2.7.2
  http: ^1.1.0
```

## 许可证

MIT License 