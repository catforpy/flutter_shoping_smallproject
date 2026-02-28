import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../interceptors/interceptor.dart' show Interceptor;
import '../models/request_options.dart' show RequestOptions, RequestMethod;
import '../models/response.dart' show ApiResponse;

/// HTTP 客户端
final class HttpClient {
  /// 基础 URL
  final String baseUrl;

  /// 拦截器列表
  final List<Interceptor> interceptors;

  /// HTTP 客户端
  late final http.Client _client;

  HttpClient({
    this.baseUrl = '',
    this.interceptors = const [],
  }) : _client = http.Client();

  /// 发起请求
  Future<ApiResponse<dynamic>> request(RequestOptions options) async {
    // 1. 请求拦截器链
    var processedOptions = options;
    for (final interceptor in interceptors) {
      processedOptions = await interceptor.onRequest(processedOptions);
    }

    // 2. 构建完整 URL
    final fullUrl = _buildFullUrl(processedOptions.url);

    // 3. 发起 HTTP 请求
    late http.Response response;
    try {
      response = await _performRequest(
        fullUrl,
        processedOptions.method,
        processedOptions.headers,
        processedOptions.body,
      );
    } catch (e) {
      // 4. 错误拦截器链
      for (final interceptor in interceptors) {
        await interceptor.onError(e);
      }
      rethrow;
    }

    // 5. 构建响应对象
    final apiResponse = ApiResponse<dynamic>(
      statusCode: response.statusCode,
      data: _parseResponseData(response.body),
      headers: _parseHeaders(response.headers),
      statusMessage: response.reasonPhrase,
    );

    // 6. 响应拦截器链
    ApiResponse<dynamic> processedResponse = apiResponse;
    for (final interceptor in interceptors) {
      processedResponse = await interceptor.onResponse(processedResponse);
    }

    return processedResponse;
  }

  /// GET 请求
  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
  }) {
    return request(RequestOptions(
      url: path,
      method: RequestMethod.get,
      headers: headers,
      queryParameters: queryParameters,
      requireAuth: requireAuth,
    ));
  }

  /// POST 请求
  Future<ApiResponse<dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool requireAuth = true,
  }) {
    return request(RequestOptions(
      url: path,
      method: RequestMethod.post,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      requireAuth: requireAuth,
    ));
  }

  /// PUT 请求
  Future<ApiResponse<dynamic>> put(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool requireAuth = true,
  }) {
    return request(RequestOptions(
      url: path,
      method: RequestMethod.put,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      requireAuth: requireAuth,
    ));
  }

  /// DELETE 请求
  Future<ApiResponse<dynamic>> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool requireAuth = true,
  }) {
    return request(RequestOptions(
      url: path,
      method: RequestMethod.delete,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      requireAuth: requireAuth,
    ));
  }

  /// 执行 HTTP 请求
  Future<http.Response> _performRequest(
    String url,
    RequestMethod method,
    Map<String, String>? headers,
    dynamic body,
  ) async {
    switch (method) {
      case RequestMethod.get:
        return await _client.get(Uri.parse(url), headers: headers);
      case RequestMethod.post:
        return await _client.post(
          Uri.parse(url),
          headers: headers,
          body: _encodeBody(body),
        );
      case RequestMethod.put:
        return await _client.put(
          Uri.parse(url),
          headers: headers,
          body: _encodeBody(body),
        );
      case RequestMethod.delete:
        return await _client.delete(
          Uri.parse(url),
          headers: headers,
          body: _encodeBody(body),
        );
      case RequestMethod.patch:
        return await _client.patch(
          Uri.parse(url),
          headers: headers,
          body: _encodeBody(body),
        );
      case RequestMethod.head:
        return await _client.head(Uri.parse(url), headers: headers);
    }
    // 不应该执行到这里
    throw UnsupportedError('Unsupported HTTP method: ${method.value}');
  }

  /// 构建完整 URL
  String _buildFullUrl(String url) {
    if (url.startsWith('http')) {
      return url;
    }
    return '$baseUrl$url';
  }

  /// 编码请求体
  String? _encodeBody(dynamic body) {
    if (body == null) return null;
    if (body is String) return body;
    if (body is Map || body is List) {
      return jsonEncode(body);
    }
    return body.toString();
  }

  /// 解析响应数据
  dynamic _parseResponseData(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (e) {
      return body;
    }
  }

  /// 解析响应头
  Map<String, String> _parseHeaders(Map<String, String> headers) {
    return headers.map((key, value) => MapEntry(key.toLowerCase(), value));
  }

  /// 关闭客户端
  void close() {
    _client.close();
  }
}
