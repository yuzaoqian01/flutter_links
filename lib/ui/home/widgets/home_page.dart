import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3_links/main.dart';
import 'package:web3_links/ui/home/viewmodels/wallet_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 钱包'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WalletViewModel>().refreshBalance();
            },
          ),
        ],
      ),
      body: Consumer<WalletViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('错误: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.connectWallet(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final walletInfo = viewModel.walletInfo;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '网络: ${walletInfo.networkName}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '地址: ${walletInfo.address.isEmpty ? "未连接" : walletInfo.address}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '余额: ${walletInfo.balance} ETH',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => viewModel.connectWallet(),
                    icon: const Icon(Icons.account_balance_wallet),
                    label: Text(walletInfo.address.isEmpty ? '连接钱包' : '已连接'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}