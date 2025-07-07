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
import 'package:web3_links/core/auth/supabase_state_manager.dart';
import 'package:web3_links/utils/supabase_log_interceptor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化日志拦截器
  SupabaseLogInterceptor.initialize();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    appLogger.warning('无法加载.env文件: $e');
  }
  
  await AppStorage.init();
  
  // 检查Supabase配置
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  
  if (supabaseUrl == null || supabaseAnonKey == null) {
    appLogger.error('缺少Supabase配置，请检查.env文件');
    // 使用默认值或抛出错误
    throw Exception('缺少Supabase配置。请创建.env文件并设置SUPABASE_URL和SUPABASE_ANON_KEY');
  }
  
  // 初始化Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  // 初始化状态管理器
  final stateManager = SupabaseStateManager();
  await stateManager.initialize();
  
  runApp(const MyApp());
}

final supabaseClient = Supabase.instance.client;
final appLogger = AppLogger('App');

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SupabaseStateManager()),
        ChangeNotifierProvider(create: (_) => WalletViewModel()),
      ],
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