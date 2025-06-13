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
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  // 读取布尔值
  static bool getBool(String key) => _prefs?.getBool(key) ?? false;

  // 写入布尔值
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // 删除键值
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  // 清空所有缓存
  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
