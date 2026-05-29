import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

typedef TokenProvider = String? Function();

/// Invoked when a request comes back 401. Should try to obtain a fresh access
/// token (typically via the refresh endpoint) and return true if the next
/// [TokenProvider] read will yield a valid token, or false if the session
/// could not be renewed (the caller is then treated as signed out).
typedef SessionRefresher = Future<bool> Function();

class ApiClient {
  ApiClient({
    String? baseUrl,
    this.tokenProvider,
    this.onRefresh,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final TokenProvider? tokenProvider;
  final SessionRefresher? onRefresh;
  final Duration timeout;
  final http.Client _client;

  // Shared across callers so a burst of concurrent 401s triggers exactly one
  // refresh instead of a stampede; reset once the refresh settles.
  Future<bool>? _refreshing;

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
    bool isRetry = false,
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

    // Access token likely expired: attempt a one-shot refresh, then replay the
    // request once with the new token. A failed refresh falls through and lets
    // the original 401 surface to the caller.
    if (response.statusCode == 401 &&
        onRefresh != null &&
        !isRetry &&
        await _refreshSession()) {
      return _request(method, path, body: body, query: query, isRetry: true);
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

  // Coalesces concurrent refresh attempts onto a single in-flight call.
  Future<bool> _refreshSession() {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight;
    final started = _doRefresh();
    _refreshing = started;
    return started;
  }

  Future<bool> _doRefresh() async {
    try {
      return await onRefresh!.call();
    } finally {
      _refreshing = null;
    }
  }
}
