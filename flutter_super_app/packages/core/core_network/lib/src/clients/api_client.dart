import '../interceptors/interceptor.dart' show Interceptor;
import '../models/response.dart' show ApiResponse, ApiDataResponse;
import 'http_client.dart' show HttpClient;

/// API 客户端
///
/// 封装 HttpClient，提供更高级的 API 请求功能
final class ApiClient {
  /// HTTP 客户端
  final HttpClient _httpClient;

  /// 基础 URL
  final String baseUrl;

  const ApiClient({
    required HttpClient httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient,
        baseUrl = baseUrl ?? 'https://api.example.com';

  /// GET 请求
  Future<ApiDataResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
    T Function(dynamic)? dataParser,
  }) async {
    final response = await _httpClient.get(
      path,
      headers: headers,
      queryParameters: queryParameters,
      requireAuth: requireAuth,
    );

    return _parseResponse<T>(response, dataParser);
  }

  /// POST 请求
  Future<ApiDataResponse<T>> post<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool requireAuth = true,
    T Function(dynamic)? dataParser,
  }) async {
    final response = await _httpClient.post(
      path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      requireAuth: requireAuth,
    );

    return _parseResponse<T>(response, dataParser);
  }

  /// PUT 请求
  Future<ApiDataResponse<T>> put<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool requireAuth = true,
    T Function(dynamic)? dataParser,
  }) async {
    final response = await _httpClient.put(
      path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      requireAuth: requireAuth,
    );

    return _parseResponse<T>(response, dataParser);
  }

  /// DELETE 请求
  Future<ApiDataResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool requireAuth = true,
    T Function(dynamic)? dataParser,
  }) async {
    final response = await _httpClient.delete(
      path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      requireAuth: requireAuth,
    );

    return _parseResponse<T>(response, dataParser);
  }

  /// 解析响应
  ApiDataResponse<T> _parseResponse<T>(
    ApiResponse response,
    T Function(dynamic)? dataParser,
  ) {
    if (response.data is Map<String, dynamic>) {
      return ApiDataResponse.fromJson(
        response.data as Map<String, dynamic>,
        dataParser: dataParser,
      );
    }

    return ApiDataResponse<T>(
      code: 0,
      success: true,
      data: response.data as T?,
    );
  }

  /// 添加拦截器
  void addInterceptor(Interceptor interceptor) {
    _httpClient.interceptors.add(interceptor);
  }

  /// 关闭客户端
  void close() {
    _httpClient.close();
  }
}
