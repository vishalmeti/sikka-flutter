import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

typedef TokenProvider = String? Function();

class ApiClient {
  ApiClient({
    String? baseUrl,
    this.tokenProvider,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final TokenProvider? tokenProvider;
  final Duration timeout;
  final http.Client _client;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query);
  Future<dynamic> post(String path, [Object? body]) =>
      _request('POST', path, body: body);
  Future<dynamic> put(String path, [Object? body]) =>
      _request('PUT', path, body: body);
  Future<dynamic> delete(String path) => _request('DELETE', path);

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }

    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';

    final token = tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    http.Response response;
    try {
      final streamed = await _client.send(request).timeout(timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException(statusCode: 0, message: 'Request timed out');
    } catch (e) {
      throw ApiException(statusCode: 0, message: 'Network error: $e');
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid response from server (${response.statusCode})',
      );
    }

    if (json['success'] == true) {
      return json['data'];
    }

    final err = json['error'] as Map<String, dynamic>?;
    throw ApiException(
      statusCode: response.statusCode,
      message: (err?['message'] as String?) ?? 'Request failed',
      code: err?['code'] as String?,
    );
  }
}
