import 'package:flutter/foundation.dart';
// import 'package:web3dart/web3dart.dart';
import 'package:web3_links/data/models/wallet_info.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletInfo _walletInfo = WalletInfo.empty();
  bool _isLoading = false;
  String? _error;

  WalletInfo get walletInfo => _walletInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> connectWallet() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 这里需要实现具体的钱包连接逻辑，比如使用web3dart连接MetaMask等

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBalance() async {
    try {
      _isLoading = true;
      notifyListeners();

      // 使用web3dart获取当前钱包余额

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 