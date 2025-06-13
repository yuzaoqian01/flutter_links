import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3_links/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import 'package:web3_links/core/theme/theme.dart';
import 'package:web3_links/routers/routes.dart';
import 'package:web3_links/ui/home/view_models/wallet_view_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3_links/utils/app_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AppStorage.init();
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY')
  );
  runApp(const MyApp());
}

final appLogger = AppLogger('app');
final supabaseClient = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final ThemeData _lightTheme = AppTheme.light;
  // final ThemeData _darkTheme = AppTheme.dark;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WalletViewModel(),
      child: MaterialApp.router(
        title: 'Web3 Links',
        theme: FlexThemeData.light(scheme: FlexScheme.shadNeutral),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.shadNeutral),
        themeMode: ThemeMode.system,
        routerConfig: router,
        debugShowCheckedModeBanner: false
      ),
    );
  }
}