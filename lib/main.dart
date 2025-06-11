import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3_links/utils/logger.dart';
import 'package:web3_links/core/theme/theme.dart';
import 'package:web3_links/routers/routes.dart';
import 'package:web3_links/ui/home/view_models/wallet_view_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

final appLogger = AppLogger('app');

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeData _lightTheme = AppTheme.light;
  final ThemeData _darkTheme = AppTheme.dark;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WalletViewModel(),
      child: MaterialApp.router(
        title: 'Web3 Links',
        theme: _lightTheme,
        darkTheme: _darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
        debugShowCheckedModeBanner: false
      ),
    );
  }
}