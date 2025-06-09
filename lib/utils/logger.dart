import 'package:logging/logging.dart';

class AppLogger {
  final String name;
  final _logger = Logger('app');

  AppLogger(this.name);

  void info(String message) {
    _logger.info('$name: $message');
  }

  void warning(String message) {
    _logger.warning('$name: $message');
  }

  void error(String message) {
    _logger.severe('$name: $message');
  }

  void debug(String message) {
    _logger.fine('$name: $message');
  }

} 