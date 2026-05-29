import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/auth_api.dart';

class StoredSession {
  StoredSession({this.accessToken, this.refreshToken, this.user, this.pendingRole});
  final String? accessToken;
  final String? refreshToken;
  final UserProfile? user;
  final String? pendingRole;
}

class AuthStorage {
  static const _kAccess = 'auth.access_token';
  static const _kRefresh = 'auth.refresh_token';
  static const _kUser = 'auth.user';
  static const _kPendingRole = 'auth.pending_role';

  Future<StoredSession> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_kUser);
    UserProfile? user;
    if (userJson != null) {
      try {
        user = UserProfile.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        user = null;
      }
    }
    return StoredSession(
      accessToken: prefs.getString(_kAccess),
      refreshToken: prefs.getString(_kRefresh),
      user: user,
      pendingRole: prefs.getString(_kPendingRole),
    );
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, accessToken);
    await prefs.setString(_kRefresh, refreshToken);
  }

  Future<void> saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUser, jsonEncode(user.toJson()));
  }

  Future<void> savePendingRole(String? role) async {
    final prefs = await SharedPreferences.getInstance();
    if (role == null) {
      await prefs.remove(_kPendingRole);
    } else {
      await prefs.setString(_kPendingRole, role);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
    await prefs.remove(_kUser);
    await prefs.remove(_kPendingRole);
  }
}
