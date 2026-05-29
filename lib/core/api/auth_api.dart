import 'api_client.dart';

class TokenPair {
  TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory TokenPair.fromJson(Map<String, dynamic> j) => TokenPair(
        accessToken: j['accessToken'] as String,
        refreshToken: j['refreshToken'] as String,
      );
}

class UserProfile {
  UserProfile({
    required this.id,
    required this.username,
    this.name,
    required this.role,
  });

  final String id;
  final String username;
  final String? name;
  final String role;

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        username: j['username'] as String,
        name: j['name'] as String?,
        role: j['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'role': role,
      };
}

class AuthResult {
  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserProfile user;

  factory AuthResult.fromJson(Map<String, dynamic> j) => AuthResult(
        accessToken: j['accessToken'] as String,
        refreshToken: j['refreshToken'] as String,
        user: UserProfile.fromJson(j['user'] as Map<String, dynamic>),
      );
}

class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  Future<AuthResult> register({
    required String username,
    required String password,
    required String role,
    String? name,
  }) async {
    final body = <String, dynamic>{
      'username': username,
      'password': password,
      'role': role,
    };
    if (name != null && name.isNotEmpty) body['name'] = name;
    final data = await _client.post('/auth/register', body) as Map<String, dynamic>;
    return AuthResult.fromJson(data);
  }

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final data = await _client.post('/auth/login', {
      'username': username,
      'password': password,
    }) as Map<String, dynamic>;
    return AuthResult.fromJson(data);
  }

  Future<TokenPair> refresh(String refreshToken) async {
    final data = await _client.post('/auth/refresh', {
      'refreshToken': refreshToken,
    }) as Map<String, dynamic>;
    return TokenPair.fromJson(data);
  }
}
