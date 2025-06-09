class WalletInfo {
  final String address;
  final double balance;
  final String networkName;

  WalletInfo({
    required this.address,
    required this.balance,
    required this.networkName,
  });

  factory WalletInfo.empty() {
    return WalletInfo(
      address: '',
      balance: 0.0,
      networkName: 'Ethereum',
    );
  }
} 