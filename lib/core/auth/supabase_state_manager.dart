import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web3_links/utils/logger.dart';
import 'dart:async';

class SupabaseStateManager extends ChangeNotifier {
  static final SupabaseStateManager _instance = SupabaseStateManager._internal();
  factory SupabaseStateManager() => _instance;
  SupabaseStateManager._internal();

  bool _isTokenValid = true;
  bool _isInitialized = false;
  String? _currentUserId;
  final AppLogger _logger = AppLogger('supabase_state');
  Timer? _debounceTimer;
  DateTime? _lastNotifyTime;

  bool get isTokenValid => _isTokenValid;
  bool get isInitialized => _isInitialized;
  String? get currentUserId => _currentUserId;

  /// 初始化状态管理器
  Future<void> initialize() async {
    try {
      final client = Supabase.instance.client;
      
      // 监听认证状态变化
      client.auth.onAuthStateChange.listen((data) {
        _handleAuthStateChange(data);
      });

      // 检查当前会话状态
      final session = client.auth.currentSession;
      _currentUserId = session?.user.id;
      _isTokenValid = session != null && !_isTokenExpired(session);
      _isInitialized = true;
      
      _logger.info('Supabase状态管理器初始化完成');
      _safeNotifyListeners();
    } catch (e) {
      _logger.error('Supabase状态管理器初始化失败: $e');
    }
  }

  /// 处理认证状态变化
  void _handleAuthStateChange(AuthState data) {
    final event = data.event;
    final session = data.session;
    
    _logger.info('认证状态变化: $event');
    
    switch (event) {
      case AuthChangeEvent.signedIn:
        _currentUserId = session?.user.id;
        _isTokenValid = session != null && !_isTokenExpired(session);
        _logger.info('用户登录成功: ${session?.user.id}');
        _safeNotifyListeners();
        break;
        
      case AuthChangeEvent.signedOut:
        _currentUserId = null;
        _isTokenValid = false;
        _logger.info('用户登出');
        _safeNotifyListeners();
        break;
        
      case AuthChangeEvent.tokenRefreshed:
        // Token刷新时，只有在token真正失效时才通知
        if (session != null && _isTokenExpired(session)) {
          _isTokenValid = false;
          _logger.warning('Token已失效');
          _safeNotifyListeners();
        } else {
          _logger.info('Token刷新成功，无需界面更新');
        }
        break;
        
      case AuthChangeEvent.userUpdated:
        _currentUserId = session?.user.id;
        _logger.info('用户信息更新');
        break;
        
      default:
        // 其他事件不触发界面更新
        _logger.info('认证事件: $event (不触发界面更新)');
        break;
    }
  }

  /// 检查token是否即将过期（5分钟内）
  bool _isTokenExpired(Session session) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return true;
    
    final now = DateTime.now();
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    final timeUntilExpiry = expiryTime.difference(now);
    
    // 如果token在5分钟内过期，认为已失效
    return timeUntilExpiry.inMinutes < 5;
  }

  /// 安全的通知监听器，带防抖机制
  void _safeNotifyListeners() {
    final now = DateTime.now();
    
    // 如果距离上次通知不到1秒，则延迟通知
    if (_lastNotifyTime != null && 
        now.difference(_lastNotifyTime!).inMilliseconds < 1000) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _lastNotifyTime = DateTime.now();
        notifyListeners();
      });
    } else {
      _lastNotifyTime = now;
      notifyListeners();
    }
  }

  /// 检查token是否有效
  bool isSessionValid() {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null && !_isTokenExpired(session);
  }

  /// 获取当前用户ID
  String? getUserId() {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  /// 强制刷新状态（仅在必要时调用）
  void forceRefresh() {
    _logger.info('强制刷新Supabase状态');
    _safeNotifyListeners();
  }

  /// 清理资源
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _logger.info('Supabase状态管理器已清理');
    super.dispose();
  }
} 