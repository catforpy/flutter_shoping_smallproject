import 'package:sqflite/sqflite.dart';
import 'package:core_logging/core_logging.dart';
import 'package:core_base/core_base.dart';
import '../database/app_database.dart';
import '../exceptions/database_exceptions.dart';
import 'base_entity.dart';

/// 基础仓储类
///
/// 提供通用的数据库 CRUD 操作
abstract base class BaseRepository<T extends DatabaseEntity> {
  final AppDatabase _database;

  BaseRepository(this._database);

  /// 获取数据库实例
  Future<Database> get _db => _database.database;

  /// 获取表名
  String get tableName;

  /// 从 Map 创建实体
  T fromMap(Map<String, dynamic> map);

  /// 插入数据
  Future<Result<String>> insert(T entity) async {
    try {
      final db = await _db;
      final map = entity.toMap();

      // 如果没有 ID，生成一个
      if (map['id'] == null) {
        map['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // 添加时间戳
      map['createdAt'] = DateTime.now().toIso8601String();
      map['updatedAt'] = DateTime.now().toIso8601String();

      final id = await db.insert(
        tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      Log.i('插入数据成功: $tableName, id: $id');
      return Result.success(id.toString());
    } catch (e) {
      Log.e('插入数据失败: $tableName', error: e);
      return Result.failure(
        DatabaseWriteException(
          message: '插入数据失败: $tableName',
          originalException: e,
        ),
      );
    }
  }

  /// 批量插入数据
  Future<Result<void>> insertBatch(List<T> entities) async {
    try {
      final db = await _db;
      final batch = db.batch();

      for (final entity in entities) {
        final map = entity.toMap();

        if (map['id'] == null) {
          map['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        }

        map['createdAt'] = DateTime.now().toIso8601String();
        map['updatedAt'] = DateTime.now().toIso8601String();

        batch.insert(
          tableName,
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      Log.i('批量插入数据成功: $tableName, count: ${entities.length}');
      return Result.success(null);
    } catch (e) {
      Log.e('批量插入数据失败: $tableName', error: e);
      return Result.failure(
        DatabaseWriteException(
          message: '批量插入数据失败: $tableName',
          originalException: e,
        ),
      );
    }
  }

  /// 查询所有数据
  Future<Result<List<T>>> findAll() async {
    try {
      final db = await _db;
      final maps = await db.query(
        tableName,
        orderBy: 'createdAt DESC',
      );

      final entities = maps.map((map) => fromMap(map)).toList();
      Log.i('查询所有数据成功: $tableName, count: ${entities.length}');
      return Result.success(entities);
    } catch (e) {
      Log.e('查询所有数据失败: $tableName', error: e);
      return Result.failure(
        DatabaseQueryException(
          message: '查询所有数据失败: $tableName',
          originalException: e,
        ),
      );
    }
  }

  /// 根据 ID 查询
  Future<Result<T?>> findById(String id) async {
    try {
      final db = await _db;
      final maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        Log.w('数据不存在: $tableName, id: $id');
        return Result.success(null);
      }

      final entity = fromMap(maps.first);
      Log.i('查询数据成功: $tableName, id: $id');
      return Result.success(entity);
    } catch (e) {
      Log.e('查询数据失败: $tableName, id: $id', error: e);
      return Result.failure(
        DatabaseQueryException(
          message: '查询数据失败: $tableName, id: $id',
          originalException: e,
        ),
      );
    }
  }

  /// 分页查询
  Future<Result<PagedResult<T>>> findByPage({
    int page = 1,
    int pageSize = 20,
    String orderBy = 'createdAt DESC',
  }) async {
    try {
      final db = await _db;
      final offset = (page - 1) * pageSize;

      final maps = await db.query(
        tableName,
        orderBy: orderBy,
        limit: pageSize,
        offset: offset,
      );

      // 查询总数
      final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final total = countResult.first['count'] as int;

      final entities = maps.map((map) => fromMap(map)).toList();

      final pagination = Pagination(
        page: page,
        pageSize: pageSize,
        total: total,
      );

      final pagedResult = PagedResult<T>(
        data: entities,
        pagination: pagination,
      );

      Log.i('分页查询成功: $tableName, page: $page, count: ${entities.length}');
      return Result.success(pagedResult);
    } catch (e) {
      Log.e('分页查询失败: $tableName, page: $page', error: e);
      return Result.failure(
        DatabaseQueryException(
          message: '分页查询失败: $tableName, page: $page',
          originalException: e,
        ),
      );
    }
  }

  /// 更新数据
  Future<Result<void>> update(T entity) async {
    try {
      final db = await _db;
      final map = entity.toMap();

      // 更新时间戳
      map['updatedAt'] = DateTime.now().toIso8601String();

      await db.update(
        tableName,
        map,
        where: 'id = ?',
        whereArgs: [entity.id],
      );

      Log.i('更新数据成功: $tableName, id: ${entity.id}');
      return Result.success(null);
    } catch (e) {
      Log.e('更新数据失败: $tableName, id: ${entity.id}', error: e);
      return Result.failure(
        DatabaseWriteException(
          message: '更新数据失败: $tableName, id: ${entity.id}',
          originalException: e,
        ),
      );
    }
  }

  /// 删除数据
  Future<Result<void>> delete(String id) async {
    try {
      final db = await _db;

      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      Log.i('删除数据成功: $tableName, id: $id');
      return Result.success(null);
    } catch (e) {
      Log.e('删除数据失败: $tableName, id: $id', error: e);
      return Result.failure(
        DatabaseWriteException(
          message: '删除数据失败: $tableName, id: $id',
          originalException: e,
        ),
      );
    }
  }

  /// 删除所有数据
  Future<Result<void>> deleteAll() async {
    try {
      final db = await _db;

      await db.delete(tableName);

      Log.i('删除所有数据成功: $tableName');
      return Result.success(null);
    } catch (e) {
      Log.e('删除所有数据失败: $tableName', error: e);
      return Result.failure(
        DatabaseWriteException(
          message: '删除所有数据失败: $tableName',
          originalException: e,
        ),
      );
    }
  }

  /// 查询数据总数
  Future<Result<int>> count() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final count = result.first['count'] as int;

      Log.i('查询数据总数成功: $tableName, count: $count');
      return Result.success(count);
    } catch (e) {
      Log.e('查询数据总数失败: $tableName', error: e);
      return Result.failure(
        DatabaseQueryException(
          message: '查询数据总数失败: $tableName',
          originalException: e,
        ),
      );
    }
  }

  /// 执行原始查询
  Future<Result<List<Map<String, dynamic>>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    try {
      final db = await _db;
      final result = await db.rawQuery(sql, arguments);

      Log.i('执行原始查询成功: $sql');
      return Result.success(result);
    } catch (e) {
      Log.e('执行原始查询失败: $sql', error: e);
      return Result.failure(
        DatabaseQueryException(
          message: '执行原始查询失败: $sql',
          originalException: e,
        ),
      );
    }
  }
}
