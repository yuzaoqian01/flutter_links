import 'package:logging/logging.dart';

class AppLogger {
  final String name;
  final _logger = Logger('app');

  AppLogger(this.name) {
    // 配置日志级别
    Logger.root.level = Level.ALL;
    // 添加日志输出处理器
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  void info(String message) {
    _logger.info('$name: $message');
  }

  void warning(String message) {
    _logger.warning('$name: $message');
  }

  void error(String message) {
    _logger.severe('$name: $message');
  }
} 