import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web3_links/main.dart';

Future<AuthResponse> loginWithEmail(String email, String password) async {
  try {
    appLogger.info('开始Supabase登录请求');
    

    
    final res = await supabaseClient.auth.signInWithPassword(
      email: email, 
      password: password
    );
    
    if (res.user != null && res.session != null) {
      appLogger.info('用户登录成功: ${res.user!.email}');
      return res;
    } else {
      appLogger.warning('登录响应中用户或会话为空');
      throw Exception('登录失败：用户信息无效');
    }
  } on AuthException catch (e) {
    appLogger.error('Supabase认证异常: ${e.message}');
    throw Exception('认证失败: ${e.message}');
  } on SocketException catch (e) {
    appLogger.error('网络连接异常: ${e.message}');
    throw Exception('网络连接失败，请检查网络设置');
  } catch (e) {
    appLogger.error('登录服务异常: $e');
    throw Exception('登录失败: $e');
  }
}
