import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:core_logging/core_logging.dart';
import '../exceptions/database_exceptions.dart';

/// 应用数据库类
///
/// 提供数据库初始化、连接管理、事务支持
final class AppDatabase {
  final String _databaseName;
  final int _databaseVersion;
  Database? _database;

  AppDatabase({
    String databaseName = 'app_database.db',
    int databaseVersion = 1,
  })  : _databaseName = databaseName,
        _databaseVersion = databaseVersion;

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);

      Log.i('初始化数据库: $path');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      Log.e('数据库初始化失败', error: e);
      throw DatabaseInitException(
        originalException: e,
      );
    }
  }

  /// 数据库配置
  Future<void> _onConfigure(Database db) async {
    // 启用外键约束
    await db.execute('PRAGMA foreign_keys = ON');
    Log.i('数据库配置完成：外键约束已启用');
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    Log.i('创建数据库表，版本: $version');
    // 子类应该实现具体的表创建逻辑
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Log.i('升级数据库: $oldVersion -> $newVersion');
    // 子类应该实现具体的升级逻辑
  }

  /// 执行事务
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    try {
      return await db.transaction(action);
    } catch (e) {
      Log.e('事务执行失败', error: e);
      rethrow;
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      Log.i('数据库已关闭');
    }
  }

  /// 删除数据库
  Future<void> delete() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
      Log.i('数据库已删除: $path');
    } catch (e) {
      Log.e('删除数据库失败', error: e);
      throw DatabaseInitException(
        message: '删除数据库失败',
        originalException: e,
      );
    }
  }
}
