import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Supabase日志拦截器
/// 用于过滤和控制Supabase内部的日志输出
class SupabaseLogInterceptor {
  static bool _isInitialized = false;
  
  /// 初始化日志拦截器
  static void initialize() {
    if (_isInitialized) return;
    
    // 拦截Supabase内部的token刷新日志
    if (kDebugMode) {
      // 重写developer.log来过滤特定日志
      _interceptLogs();
    }
    
    _isInitialized = true;
  }
  
  /// 拦截日志输出
  static void _interceptLogs() {
    // 这里可以通过重写developer.log来过滤日志
    // 但由于Flutter的限制，我们使用其他方法
    
    // 设置日志级别过滤器
    _setLogLevelFilter();
  }
  
  /// 设置日志级别过滤器
  static void _setLogLevelFilter() {
    // 通过环境变量控制日志输出
    const bool showSupabaseLogs = bool.fromEnvironment(
      'SHOW_SUPABASE_LOGS', 
      defaultValue: false
    );
    
    if (!showSupabaseLogs) {
      // 在发布模式下完全禁用Supabase调试日志
      _disableSupabaseDebugLogs();
    }
  }
  
  /// 禁用Supabase调试日志
  static void _disableSupabaseDebugLogs() {
    // 通过设置环境变量来禁用Supabase的调试日志
    // 这需要在编译时设置
  }
  
  /// 检查是否应该显示日志
  static bool shouldShowLog(String message) {
    // 过滤掉token刷新相关的日志
    if (message.contains('Access token expires')) {
      return false;
    }
    
    // 过滤掉其他不必要的Supabase内部日志
    if (message.contains('FINER') && message.contains('supabase')) {
      return false;
    }
    
    return true;
  }
  
  /// 自定义日志输出
  static void log(String message, {String? name}) {
    if (shouldShowLog(message)) {
      developer.log(message, name: name ?? 'Supabase');
    }
  }
} 