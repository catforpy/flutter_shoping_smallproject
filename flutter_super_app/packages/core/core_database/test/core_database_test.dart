import 'package:flutter_test/flutter_test.dart';
import 'package:core_database/core_database.dart';

// 测试实体
final class TestEntity extends DatabaseEntity {
  @override
  String get tableName => 'test_table';

  final String? testId;
  final String name;

  const TestEntity({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.testId,
    required this.name,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testId': testId,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String get createTableSql => '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      testId TEXT,
      name TEXT NOT NULL,
      createdAt TEXT,
      updatedAt TEXT
    )
  ''';

  @override
  List<String> get columns => ['id', 'testId', 'name', 'createdAt', 'updatedAt'];

  TestEntity copyWith({
    String? id,
    String? testId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestEntity(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

void main() {
  group('DatabaseException', () {
    test('should create init exception with default values', () {
      const exception = DatabaseInitException();
      expect(exception.code, 'DATABASE_INIT_ERROR');
      expect(exception.message, '数据库初始化失败');
    });

    test('should create query exception with custom values', () {
      const exception = DatabaseQueryException(
        message: '自定义错误',
        originalException: 'Test error',
      );
      expect(exception.code, 'DATABASE_QUERY_ERROR');
      expect(exception.message, '自定义错误');
      expect(exception.originalException, 'Test error');
    });

    test('should create table not found exception', () {
      const exception = TableNotFoundException(
        message: '表不存在',
      );
      expect(exception.code, 'TABLE_NOT_FOUND');
      expect(exception.message, '表不存在');
    });

    test('should create transaction exception', () {
      const exception = DatabaseTransactionException(
        message: '事务失败',
      );
      expect(exception.code, 'DATABASE_TRANSACTION_ERROR');
      expect(exception.message, '事务失败');
    });

    test('should create write exception', () {
      const exception = DatabaseWriteException(
        message: '写入失败',
      );
      expect(exception.code, 'DATABASE_WRITE_ERROR');
      expect(exception.message, '写入失败');
    });
  });

  group('TestEntity', () {
    test('should create entity with required fields', () {
      const entity = TestEntity(name: 'Test');
      expect(entity.name, 'Test');
      expect(entity.id, null);
      expect(entity.createdAt, null);
      expect(entity.updatedAt, null);
    });

    test('should create entity with all fields', () {
      const entity = TestEntity(
        id: '123',
        name: 'Test',
        createdAt: null,
        updatedAt: null,
      );
      expect(entity.id, '123');
      expect(entity.name, 'Test');
    });

    test('should convert to map correctly', () {
      const entity = TestEntity(
        id: '123',
        name: 'Test',
      );
      final map = entity.toMap();
      expect(map['id'], '123');
      expect(map['name'], 'Test');
      expect(map['testId'], null);
    });

    test('should get correct table name', () {
      const entity = TestEntity(name: 'Test');
      expect(entity.tableName, 'test_table');
    });

    test('should get correct columns', () {
      const entity = TestEntity(name: 'Test');
      expect(entity.columns.length, 5);
      expect(entity.columns, contains('id'));
      expect(entity.columns, contains('name'));
    });

    test('should get create table SQL', () {
      const entity = TestEntity(name: 'Test');
      final sql = entity.createTableSql;
      expect(sql, contains('CREATE TABLE test_table'));
      expect(sql, contains('id TEXT PRIMARY KEY'));
      expect(sql, contains('name TEXT NOT NULL'));
    });

    test('should copy with new values', () {
      const entity = TestEntity(id: '123', name: 'Test');
      final copied = entity.copyWith(name: 'Updated');
      expect(copied.id, '123');
      expect(copied.name, 'Updated');
    });
  });

  group('AppDatabase', () {
    test('should create database instance with default values', () {
      final database = AppDatabase();
      expect(database, isNotNull);
    });

    test('should create database instance with custom values', () {
      final database = AppDatabase(
        databaseName: 'custom.db',
        databaseVersion: 2,
      );
      expect(database, isNotNull);
    });
  });

  group('DatabaseEntity', () {
    test('should have correct base properties', () {
      final createdAt = DateTime(2026, 1, 1);
      final updatedAt = DateTime(2026, 1, 2);
      final entity = TestEntity(
        id: 'test-id',
        createdAt: createdAt,
        updatedAt: updatedAt,
        name: 'Test',
      );

      expect(entity.id, 'test-id');
      expect(entity.createdAt, createdAt);
      expect(entity.updatedAt, updatedAt);
    });

    test('should support null id for new entities', () {
      const entity = TestEntity(
        id: null,
        name: 'New Entity',
      );
      expect(entity.id, null);
    });
  });
}
