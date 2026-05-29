import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sikka/core/api/api_client.dart';
import 'package:sikka/core/api/api_exception.dart';

http.Response _json(int status, Map<String, dynamic> body) => http.Response(
      jsonEncode(body),
      status,
      headers: const {'content-type': 'application/json'},
    );

http.Response _ok(Object? data) => _json(200, {'success': true, 'data': data});

http.Response _unauthorized() => _json(401, {
      'success': false,
      'error': {'message': 'Invalid or expired token'},
    });

void main() {
  test('refreshes once on 401 then replays the request with the new token',
      () async {
    var token = 'expired';
    var refreshCalls = 0;
    var protectedCalls = 0;

    final client = ApiClient(
      baseUrl: 'http://test.local/api',
      tokenProvider: () => token,
      onRefresh: () async {
        refreshCalls++;
        token = 'fresh';
        return true;
      },
      client: MockClient((req) async {
        protectedCalls++;
        return req.headers['Authorization'] == 'Bearer fresh'
            ? _ok({'value': 42})
            : _unauthorized();
      }),
    );

    final data = await client.get('/wallets/dashboard');

    expect(data, {'value': 42});
    expect(refreshCalls, 1);
    expect(protectedCalls, 2); // original 401 + replayed success
  });

  test('a burst of concurrent 401s shares a single refresh', () async {
    var token = 'expired';
    var refreshCalls = 0;

    final client = ApiClient(
      baseUrl: 'http://test.local/api',
      tokenProvider: () => token,
      onRefresh: () async {
        refreshCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        token = 'fresh';
        return true;
      },
      client: MockClient((req) async {
        return req.headers['Authorization'] == 'Bearer fresh'
            ? _ok({'ok': true})
            : _unauthorized();
      }),
    );

    final results = await Future.wait([
      client.get('/a'),
      client.get('/b'),
      client.get('/c'),
    ]);

    expect(results, [
      {'ok': true},
      {'ok': true},
      {'ok': true},
    ]);
    expect(refreshCalls, 1);
  });

  test('a failed refresh surfaces the original 401 without looping', () async {
    var refreshCalls = 0;
    var protectedCalls = 0;

    final client = ApiClient(
      baseUrl: 'http://test.local/api',
      tokenProvider: () => 'expired',
      onRefresh: () async {
        refreshCalls++;
        return false;
      },
      client: MockClient((req) async {
        protectedCalls++;
        return _unauthorized();
      }),
    );

    ApiException? caught;
    try {
      await client.get('/x');
    } on ApiException catch (e) {
      caught = e;
    }

    expect(caught?.statusCode, 401);
    expect(refreshCalls, 1);
    expect(protectedCalls, 1); // no replay when the refresh fails
  });

  test('replays at most once even if the refreshed token is still rejected',
      () async {
    var refreshCalls = 0;
    var protectedCalls = 0;

    final client = ApiClient(
      baseUrl: 'http://test.local/api',
      tokenProvider: () => 'expired',
      onRefresh: () async {
        refreshCalls++;
        return true; // claims success, but the server keeps rejecting
      },
      client: MockClient((req) async {
        protectedCalls++;
        return _unauthorized();
      }),
    );

    ApiException? caught;
    try {
      await client.get('/x');
    } on ApiException catch (e) {
      caught = e;
    }

    expect(caught?.statusCode, 401);
    expect(refreshCalls, 1); // not invoked again on the replay
    expect(protectedCalls, 2); // original + one replay, then gives up
  });

  test('without an onRefresh hook a 401 throws immediately', () async {
    var protectedCalls = 0;

    final client = ApiClient(
      baseUrl: 'http://test.local/api',
      tokenProvider: () => 'expired',
      client: MockClient((req) async {
        protectedCalls++;
        return _unauthorized();
      }),
    );

    ApiException? caught;
    try {
      await client.get('/x');
    } on ApiException catch (e) {
      caught = e;
    }

    expect(caught?.statusCode, 401);
    expect(protectedCalls, 1);
  });

  test('a successful request never triggers a refresh', () async {
    var refreshCalls = 0;

    final client = ApiClient(
      baseUrl: 'http://test.local/api',
      tokenProvider: () => 'good',
      onRefresh: () async {
        refreshCalls++;
        return true;
      },
      client: MockClient((req) async => _ok({'fine': true})),
    );

    final data = await client.get('/ok');

    expect(data, {'fine': true});
    expect(refreshCalls, 0);
  });
}
