import 'package:flutter_test/flutter_test.dart';

import 'package:core_base/core_base.dart';

void main() {
  group('Result', () {
    test('should create success result', () {
      final result = Result.success('test');
      expect(result.isSuccess, true);
      expect(result.valueOrThrow, 'test');
    });

    test('should create failure result', () {
      final result = Result.failure(Exception('error'));
      expect(result.isFailure, true);
      expect(result.getOrElse('default'), 'default');
    });

    test('should map value', () {
      final result = Result.success(5);
      final mapped = result.map((v) => v * 2);
      expect(mapped.valueOrThrow, 10);
    });
  });

  group('Either', () {
    test('should create right value', () {
      final either = Either<int, String>.right('success');
      expect(either.isRight, true);
      expect(either.right, 'success');
    });

    test('should create left value', () {
      final either = Either<int, String>.left(404);
      expect(either.isLeft, true);
      expect(either.left, 404);
    });
  });

  group('Pagination', () {
    test('should calculate total pages correctly', () {
      final pagination = Pagination(page: 1, pageSize: 20, total: 100);
      expect(pagination.totalPages, 5);
      expect(pagination.hasNext, true);
      expect(pagination.hasPrevious, false);
    });

    test('should check if is last page', () {
      final pagination = Pagination(page: 5, pageSize: 20, total: 100);
      expect(pagination.isLast, true);
      expect(pagination.hasNext, false);
    });
  });

  group('PagedResult', () {
    test('should create paged result', () {
      final result = PagedResult<int>(
        data: [1, 2, 3],
        pagination: Pagination(page: 1, pageSize: 20, total: 100),
      );
      expect(result.length, 3);
      expect(result.isEmpty, false);
      expect(result.pagination.totalPages, 5);
    });
  });
}
