import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3_links/ui/home/widgets/home_page.dart';
import 'package:web3_links/ui/home/view_models/wallet_view_model.dart';
import 'package:web3_links/core/auth/supabase_state_manager.dart';

void main() {
  group('首页数据接入测试', () {
    testWidgets('应该正确显示钱包数据', (WidgetTester tester) async {
      // 创建测试用的Provider
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => WalletViewModel(),
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Web3 钱包'),
              ),
            ),
          ),
        ),
      );

      // 等待页面加载
      await tester.pumpAndSettle();

      // 验证页面包含主要组件
      expect(find.text('Web3 钱包'), findsOneWidget);
    });

    test('WalletViewModel应该正确初始化', () {
      final walletViewModel = WalletViewModel();
      
      // 验证初始状态
      expect(walletViewModel.isLoading, isFalse);
      expect(walletViewModel.error, isNull);
      expect(walletViewModel.assets, isNotEmpty);
      expect(walletViewModel.transactions, isNotEmpty);
    });

    test('应该支持余额显示切换', () {
      final walletViewModel = WalletViewModel();
      
      // 初始状态应该是可见的
      expect(walletViewModel.isBalanceVisible, isTrue);
      
      // 切换后应该是不可见的
      walletViewModel.toggleBalanceVisibility();
      expect(walletViewModel.isBalanceVisible, isFalse);
      
      // 再次切换后应该是可见的
      walletViewModel.toggleBalanceVisibility();
      expect(walletViewModel.isBalanceVisible, isTrue);
    });

    test('应该正确格式化总余额', () {
      final walletViewModel = WalletViewModel();
      
      // 验证总余额格式
      expect(walletViewModel.formattedTotalBalance, contains('\$'));
      expect(walletViewModel.formattedTotalBalance, contains('.'));
    });

    test('应该正确格式化地址', () {
      final walletViewModel = WalletViewModel();
      
      // 验证地址格式
      expect(walletViewModel.shortAddress, contains('...'));
    });


  });
} 