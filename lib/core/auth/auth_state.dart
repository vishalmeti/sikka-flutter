import 'package:flutter/foundation.dart';

import '../api/auth_api.dart';
import 'auth_storage.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._storage);

  final AuthStorage _storage;

  String? _accessToken;
  String? _refreshToken;
  UserProfile? _user;
  String? _pendingRole;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserProfile? get user => _user;
  String? get pendingRole => _pendingRole;

  bool get isAuthenticated => _accessToken != null && _user != null;

  Future<void> bootstrap() async {
    final loaded = await _storage.load();
    _accessToken = loaded.accessToken;
    _refreshToken = loaded.refreshToken;
    _user = loaded.user;
    _pendingRole = loaded.pendingRole;
    notifyListeners();
  }

  Future<void> setPendingRole(String role) async {
    _pendingRole = role;
    await _storage.savePendingRole(role);
    notifyListeners();
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserProfile user,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _user = user;
    _pendingRole = null;
    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _storage.saveUser(user);
    await _storage.savePendingRole(null);
    notifyListeners();
  }

  /// Replace just the tokens after a silent refresh, keeping the signed-in
  /// user. The access token is short-lived; the refresh token rotates.
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    notifyListeners();
  }

  /// Replace the cached profile (e.g. after a phone-verification round-trip
  /// returned the freshly-linked phone) and persist it so a relaunch shows
  /// the new state without another GET /profile.
  Future<void> updateUser(UserProfile user) async {
    _user = user;
    await _storage.saveUser(user);
    notifyListeners();
  }

  Future<void> signOut() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    _pendingRole = null;
    await _storage.clear();
    notifyListeners();
  }
}
