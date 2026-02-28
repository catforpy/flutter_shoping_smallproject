import 'package:flutter_test/flutter_test.dart';

import 'package:core_network/core_network.dart';

void main() {
  group('RequestMethod', () {
    test('should have correct values', () {
      expect(RequestMethod.get.value, 'GET');
      expect(RequestMethod.post.value, 'POST');
      expect(RequestMethod.put.value, 'PUT');
      expect(RequestMethod.delete.value, 'DELETE');
      expect(RequestMethod.patch.value, 'PATCH');
      expect(RequestMethod.head.value, 'HEAD');
    });
  });

  group('RequestOptions', () {
    test('should create request options', () {
      final options = RequestOptions(
        url: '/test',
        method: RequestMethod.post,
        body: {'key': 'value'},
      );

      expect(options.url, '/test');
      expect(options.method, RequestMethod.post);
      expect(options.body, {'key': 'value'});
    });

    test('should build URL with query parameters', () {
      final options = RequestOptions(
        url: '/test',
        queryParameters: {'key1': 'value1', 'key2': 'value2'},
      );

      final builtUrl = options.buildUrl();
      expect(builtUrl, contains('key1=value1'));
      expect(builtUrl, contains('key2=value2'));
    });

    test('should copy with new values', () {
      final options = RequestOptions(url: '/test');
      final copied = options.copyWith(
        method: RequestMethod.post,
        body: {'data': 'test'},
      );

      expect(copied.url, '/test');
      expect(copied.method, RequestMethod.post);
      expect(copied.body, {'data': 'test'});
    });
  });

  group('ApiResponse', () {
    test('should create success response', () {
      final response = ApiResponse(
        statusCode: 200,
        data: {'result': 'success'},
      );

      expect(response.isSuccess, true);
      expect(response.data, {'result': 'success'});
    });

    test('should create error response', () {
      final response = ApiResponse(
        statusCode: 404,
        statusMessage: 'Not Found',
      );

      expect(response.isClientError, true);
      expect(response.statusCode, 404);
    });

    test('should create server error response', () {
      final response = ApiResponse(statusCode: 500);

      expect(response.isServerError, true);
    });

    test('should map data', () {
      final response = ApiResponse<int>(
        statusCode: 200,
        data: 5,
      );

      final mapped = response.map((v) => v * 2);
      expect(mapped.data, 10);
    });
  });

  group('ApiDataResponse', () {
    test('should create success response', () {
      final response = const ApiDataResponse(
        code: 0,
        success: true,
        data: 'test data',
      );

      expect(response.success, true);
      expect(response.data, 'test data');
    });

    test('should create from JSON', () {
      final json = {
        'code': 0,
        'message': 'Success',
        'data': {'id': 1},
        'success': true,
      };

      final response = ApiDataResponse.fromJson(json);
      expect(response.code, 0);
      expect(response.message, 'Success');
      expect(response.success, true);
    });

    test('should convert to JSON', () {
      final response = const ApiDataResponse(
        code: 0,
        success: true,
        data: 'test',
      );

      final json = response.toJson();
      expect(json['code'], 0);
      expect(json['success'], true);
      expect(json['data'], 'test');
    });
  });

  group('Interceptor', () {
    test('should process request through interceptor', () async {
      final interceptor = TestInterceptor();
      final options = RequestOptions(url: '/test');

      final processed = await interceptor.onRequest(options);
      expect(processed.url, '/test');
    });

    test('should process response through interceptor', () async {
      final interceptor = TestInterceptor();
      final response = ApiResponse<dynamic>(
        statusCode: 200,
        data: 'test',
      );

      final processed = await interceptor.onResponse(response);
      expect(processed.statusCode, 200);
    });
  });

  group('HttpClient', () {
    test('should create HTTP client', () {
      final client = HttpClient(
        baseUrl: 'https://api.example.com',
      );

      expect(client.baseUrl, 'https://api.example.com');
      expect(client.interceptors, isEmpty);

      client.close();
    });

    test('should create client with interceptors', () {
      final interceptor = TestInterceptor();
      final client = HttpClient(
        baseUrl: 'https://api.example.com',
        interceptors: [interceptor],
      );

      expect(client.interceptors.length, 1);

      client.close();
    });
  });

  group('ApiClient', () {
    test('should create API client', () {
      final httpClient = HttpClient();
      final client = ApiClient(
        httpClient: httpClient,
        baseUrl: 'https://api.example.com',
      );

      expect(client.baseUrl, 'https://api.example.com');

      client.close();
      httpClient.close();
    });

    test('should use default base URL', () {
      final httpClient = HttpClient();
      final client = ApiClient(httpClient: httpClient);

      expect(client.baseUrl, 'https://api.example.com');

      client.close();
      httpClient.close();
    });
  });
}

// Test interceptor
final class TestInterceptor extends BaseInterceptor {
  const TestInterceptor();
}
