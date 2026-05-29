import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dashboard_api.dart';

/// Holds the customer home dashboard app-wide so it survives tab switches.
/// Call [load] when the home screen mounts; it fetches only once unless
/// [refresh] (pull-to-refresh) or [retry] (after an error) is invoked.
class CustomerHomeStore extends ChangeNotifier {
  CustomerHomeStore(this._api);

  final DashboardApi _api;

  CustomerDashboard? _data;
  bool _loading = false;
  String? _error;

  CustomerDashboard? get data => _data;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get hasData => _data != null;

  Future<void> load() async {
    if (_data != null || _loading) return;
    await _fetch(showLoader: true);
  }

  Future<void> refresh() => _fetch(showLoader: false);

  Future<void> retry() => _fetch(showLoader: true);

  Future<void> _fetch({required bool showLoader}) async {
    if (showLoader) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _data = await _api.fetch();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Drop cached data on sign-out so the next user starts clean.
  void clear() {
    _data = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }
}
