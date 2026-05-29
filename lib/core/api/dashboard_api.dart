import 'api_client.dart';

class DashboardStore {
  DashboardStore({
    required this.id,
    required this.name,
    required this.coins,
    required this.totalEarned,
    required this.tier,
    required this.tierProgress,
    required this.visits,
  });

  final String id;
  final String name;
  final int coins;
  final int totalEarned;
  final String tier;
  final double tierProgress;
  final int visits;

  factory DashboardStore.fromJson(Map<String, dynamic> j) => DashboardStore(
        id: j['id'] as String,
        name: j['name'] as String,
        coins: (j['coins'] as num).toInt(),
        totalEarned: (j['totalEarned'] as num).toInt(),
        tier: j['tier'] as String,
        tierProgress: (j['tierProgress'] as num).toDouble(),
        visits: (j['visits'] as num).toInt(),
      );
}

class DashboardActivity {
  DashboardActivity({
    required this.id,
    required this.kind,
    this.storeName,
    required this.coinDelta,
    required this.label,
    required this.timestamp,
  });

  final String id;
  final String kind; // 'earn' | 'redeem'
  final String? storeName;
  final int coinDelta;
  final String label;
  final DateTime timestamp;

  factory DashboardActivity.fromJson(Map<String, dynamic> j) =>
      DashboardActivity(
        id: j['id'] as String,
        kind: j['kind'] as String,
        storeName: j['storeName'] as String?,
        coinDelta: (j['coinDelta'] as num).toInt(),
        label: j['label'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
      );
}

class CustomerDashboard {
  CustomerDashboard({
    required this.userName,
    required this.totalCoins,
    required this.totalEarned,
    required this.overallProgress,
    required this.redeemRate,
    required this.streakDays,
    required this.stores,
    required this.activity,
  });

  final String userName;
  final int totalCoins;
  final int totalEarned;
  final double overallProgress;
  final double redeemRate;
  final int streakDays;
  final List<DashboardStore> stores;
  final List<DashboardActivity> activity;

  factory CustomerDashboard.fromJson(Map<String, dynamic> j) =>
      CustomerDashboard(
        userName: j['userName'] as String,
        totalCoins: (j['totalCoins'] as num).toInt(),
        totalEarned: (j['totalEarned'] as num).toInt(),
        overallProgress: (j['overallProgress'] as num).toDouble(),
        redeemRate: (j['redeemRate'] as num).toDouble(),
        streakDays: (j['streakDays'] as num).toInt(),
        stores: ((j['stores'] as List?) ?? const [])
            .map((e) => DashboardStore.fromJson(e as Map<String, dynamic>))
            .toList(),
        activity: ((j['activity'] as List?) ?? const [])
            .map((e) => DashboardActivity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class DashboardApi {
  DashboardApi(this._client);
  final ApiClient _client;

  Future<CustomerDashboard> fetch() async {
    final data = await _client.get('/wallets/dashboard') as Map<String, dynamic>;
    return CustomerDashboard.fromJson(data);
  }
}
