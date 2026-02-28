import 'package:flutter_test/flutter_test.dart';
import 'package:core_state/core_state.dart';

void main() {
  group('AppState', () {
    test('IdleState should be identified correctly', () {
      const state = IdleState();
      expect(state.isIdle, true);
      expect(state.isLoading, false);
      expect(state.isSuccess, false);
      expect(state.isError, false);
    });

    test('LoadingState should be identified correctly', () {
      const state = LoadingState(message: 'Loading...');
      expect(state.isLoading, true);
      expect(state.isIdle, false);
      expect(state.isSuccess, false);
      expect(state.isError, false);
    });

    test('SuccessState should be identified correctly', () {
      const state = SuccessState<String>('data');
      expect(state.isSuccess, true);
      expect(state.isLoading, false);
      expect(state.isIdle, false);
      expect(state.isError, false);
    });

    test('ErrorState should be identified correctly', () {
      const state = ErrorState('error');
      expect(state.isError, true);
      expect(state.isLoading, false);
      expect(state.isIdle, false);
      expect(state.isSuccess, false);
    });
  });

  group('DataState', () {
    test('should create idle state', () {
      final state = DataState<int>.idle();
      expect(state.isLoading, false);
      expect(state.data, null);
      expect(state.hasError, false);
    });

    test('should create loading state', () {
      final state = DataState<int>.loading();
      expect(state.isLoading, true);
      expect(state.data, null);
      expect(state.hasError, false);
    });

    test('should create success state', () {
      final state = DataState<int>.success(123);
      expect(state.data, 123);
      expect(state.isLoading, false);
      expect(state.hasError, false);
      expect(state.hasData, true);
    });

    test('should create error state', () {
      final error = Exception('test error');
      final state = DataState<int>.error(error);
      expect(state.error, error);
      expect(state.isLoading, false);
      expect(state.data, null);
      expect(state.hasError, true);
    });

    test('should copy with new values', () {
      final state = DataState<int>.success(123);
      final copied = state.copyWith(data: 456, isLoading: true);
      expect(copied.data, 456);
      expect(copied.isLoading, true);
      expect(state.data, 123); // Original unchanged
    });
  });

  group('UiState', () {
    test('should create initial state', () {
      final state = UiState<int>.initial();
      expect(state.isInitial, true);
      expect(state.data, null);
      expect(state.isLoading, false);
      expect(state.errorMessage, null);
    });

    test('should create loading state', () {
      final state = UiState<int>.loading();
      expect(state.isLoading, true);
      expect(state.data, null);
    });

    test('should create success state', () {
      final state = UiState<int>.success(123);
      expect(state.data, 123);
      expect(state.isLoading, false);
      expect(state.hasError, false);
      expect(state.hasData, true);
    });

    test('should create error state', () {
      final state = UiState<int>.error('error message');
      expect(state.errorMessage, 'error message');
      expect(state.hasError, true);
      expect(state.isLoading, false);
    });

    test('should copy with new values', () {
      final state = UiState<int>.success(123);
      final copied = state.copyWith(data: 456);
      expect(copied.data, 456);
      expect(state.data, 123); // Original unchanged
    });
  });

  group('PagedUiState', () {
    test('should create initial state', () {
      final state = PagedUiState<int>.initial();
      expect(state.isInitial, true);
      expect(state.data, isEmpty);
      expect(state.hasMore, true);
      expect(state.currentPage, 1);
    });

    test('should create loading state', () {
      final state = PagedUiState<int>.loading();
      expect(state.isLoading, true);
    });

    test('should create success state', () {
      final state = PagedUiState<int>.success([1, 2, 3]);
      expect(state.data, [1, 2, 3]);
      expect(state.isLoading, false);
      expect(state.hasMore, true);
    });

    test('should create error state', () {
      final state = PagedUiState<int>.error('error');
      expect(state.errorMessage, 'error');
      expect(state.hasError, true);
    });

    test('should copy with new values', () {
      final state = PagedUiState<int>.success([1, 2]);
      final copied = state.copyWith(
        data: [3, 4],
        currentPage: 2,
        hasMore: false,
      );
      expect(copied.data, [3, 4]);
      expect(copied.currentPage, 2);
      expect(copied.hasMore, false);
    });
  });

  group('UiStateProvider', () {
    test('should manage state transitions', () {
      final provider = TestUiStateProvider();

      // Initial state
      expect(provider.isInitial, true);
      expect(provider.data, null);

      // Loading
      provider.toLoading();
      expect(provider.isLoading, true);

      // Success
      provider.toSuccess('test data');
      expect(provider.data, 'test data');
      expect(provider.isLoading, false);

      // Error
      provider.toError('error message');
      expect(provider.errorMessage, 'error message');
      expect(provider.hasError, true);
    });

    test('should reset state', () {
      final provider = TestUiStateProvider();
      provider.toSuccess('data');
      provider.reset();
      expect(provider.isInitial, true);
    });
  });

  group('PagedStateProvider', () {
    test('should manage paged data', () {
      final provider = TestPagedStateProvider();

      // Initial
      expect(provider.isEmpty, true);
      expect(provider.hasMore, true);

      // Success
      provider.toSuccess([1, 2, 3]);
      expect(provider.data, [1, 2, 3]);
      expect(provider.hasMore, true);
      expect(provider.currentPage, 1);

      // Append
      provider.appendData([4, 5], hasMore: false);
      expect(provider.data, [1, 2, 3, 4, 5]);
      expect(provider.hasMore, false);
      expect(provider.currentPage, 2);
    });

    test('should reset state', () {
      final provider = TestPagedStateProvider();
      provider.toSuccess([1, 2, 3]);
      provider.reset();
      expect(provider.isEmpty, true);
    });
  });

  group('AsyncNotifier', () {
    test('should handle successful async operations', () async {
      final notifier = TestAsyncNotifier();

      await notifier.fetch(() async {
        return 'test result';
      });

      expect(notifier.data, 'test result');
      expect(notifier.isLoading, false);
      expect(notifier.hasError, false);
    });

    test('should handle failed async operations', () async {
      final notifier = TestAsyncNotifier();

      await notifier.fetch(() async {
        throw Exception('test error');
      });

      expect(notifier.data, null);
      expect(notifier.hasError, true);
      expect(notifier.errorMessage, 'Exception: test error');
    });

    test('should reset state', () {
      final notifier = TestAsyncNotifier();
      notifier.setData('data');
      notifier.reset();
      expect(notifier.data, null);
      expect(notifier.isLoading, false);
    });

    test('should set data manually', () {
      final notifier = TestAsyncNotifier();
      notifier.setData('manual data');
      expect(notifier.data, 'manual data');
    });

    test('should set error manually', () {
      final notifier = TestAsyncNotifier();
      notifier.setError('manual error');
      expect(notifier.hasError, true);
      expect(notifier.errorMessage, 'manual error');
    });
  });
}

// Test helpers
final class TestUiStateProvider extends UiStateProvider<String> {}

final class TestPagedStateProvider extends PagedStateProvider<int> {}

final class TestAsyncNotifier extends AsyncNotifier<String> {}
