import 'package:shared_preferences/shared_preferences.dart';




class AppStorage {
  static SharedPreferences? _prefs;

  /// 初始化（在 app 启动时调用一次）
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 读取字符串
  static String? getString(String key) => _prefs?.getString(key);

  // 写入字符串
  static Future<bool> setString(String key, String? value) async {
    if (value == null) return false;
    return await _prefs?.setString(key, value) ?? false;
  }

  // 读取布尔值
  static bool getBool(String key) => _prefs?.getBool(key) ?? false;

  // 写入布尔值
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  // 删除键值
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // 清空所有缓存
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}
