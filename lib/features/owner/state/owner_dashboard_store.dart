import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/owner_api.dart';

/// Holds the owner dashboard app-wide so it survives tab/route switches.
/// Mirrors [CustomerHomeStore]: fetches once on [load], re-fetches on
/// [refresh] (pull-to-refresh) or [retry] (after an error).
class OwnerDashboardStore extends ChangeNotifier {
  OwnerDashboardStore(this._api);

  final OwnerApi _api;

  OwnerDashboard? _data;
  bool _loading = false;
  String? _error;

  OwnerDashboard? get data => _data;
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

  /// Drop cached data on sign-out so the next owner starts clean.
  void clear() {
    _data = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }
}
