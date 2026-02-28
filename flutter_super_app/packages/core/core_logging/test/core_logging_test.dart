import 'package:flutter_test/flutter_test.dart';

import 'package:core_logging/core_logging.dart';

void main() {
  group('LogLevel', () {
    test('should have correct values', () {
      expect(LogLevel.debug.value, 0);
      expect(LogLevel.info.value, 1);
      expect(LogLevel.warning.value, 2);
      expect(LogLevel.error.value, 3);
      expect(LogLevel.fatal.value, 4);
    });

    test('should check if should log', () {
      expect(LogLevel.debug.shouldLog(LogLevel.info), false);
      expect(LogLevel.info.shouldLog(LogLevel.info), true);
      expect(LogLevel.error.shouldLog(LogLevel.warning), true);
    });

    test('should convert to string', () {
      expect(LogLevel.debug.toString(), 'DEBUG');
      expect(LogLevel.info.toString(), 'INFO');
      expect(LogLevel.error.toString(), 'ERROR');
    });
  });

  group('AppLogger', () {
    late AppLogger logger;

    setUp(() {
      logger = AppLogger('TestLogger', minLevel: LogLevel.debug);
    });

    test('should log debug message', () {
      // Just verify it doesn't throw
      expect(() => logger.debug('Debug message'), returnsNormally);
    });

    test('should log info message', () {
      expect(() => logger.info('Info message'), returnsNormally);
    });

    test('should log warning message', () {
      expect(() => logger.warning('Warning message'), returnsNormally);
    });

    test('should log error message', () {
      expect(() => logger.error('Error message'), returnsNormally);
    });

    test('should log fatal message', () {
      expect(() => logger.fatal('Fatal message'), returnsNormally);
    });

    test('should respect min level', () {
      final highLevelLogger = AppLogger('High', minLevel: LogLevel.error);
      // Debug should not log when min level is error
      expect(() => highLevelLogger.debug('Should not log'), returnsNormally);
    });
  });

  group('Log', () {
    setUp(() {
      Log.init(minLevel: LogLevel.info);
    });

    test('should create root logger', () {
      expect(Log.root, isA<AppLogger>());
      expect(Log.root.tag, 'App');
    });

    test('should create logger with tag', () {
      final logger = Log.create('CustomTag');
      expect(logger.tag, 'CustomTag');
    });

    test('should log using shortcut methods', () {
      expect(() => Log.d('Debug'), returnsNormally);
      expect(() => Log.i('Info'), returnsNormally);
      expect(() => Log.w('Warning'), returnsNormally);
      expect(() => Log.e('Error'), returnsNormally);
      expect(() => Log.f('Fatal'), returnsNormally);
    });
  });
}
