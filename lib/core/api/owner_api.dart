import 'api_client.dart';

class OwnerStoreRef {
  OwnerStoreRef({required this.id, required this.name});

  final String id;
  final String name;

  factory OwnerStoreRef.fromJson(Map<String, dynamic> j) =>
      OwnerStoreRef(id: j['id'] as String, name: j['name'] as String);
}

class OwnerVisitDay {
  OwnerVisitDay({required this.day, required this.count, required this.today});

  final String day;
  final int count;
  final bool today;

  factory OwnerVisitDay.fromJson(Map<String, dynamic> j) => OwnerVisitDay(
        day: j['day'] as String,
        count: (j['count'] as num).toInt(),
        today: j['today'] as bool? ?? false,
      );
}

class OwnerPendingTop {
  OwnerPendingTop({
    required this.id,
    required this.customerName,
    required this.coins,
    required this.rupeeValue,
  });

  final String id;
  final String customerName;
  final int coins;
  final num rupeeValue;

  factory OwnerPendingTop.fromJson(Map<String, dynamic> j) => OwnerPendingTop(
        id: j['id'] as String,
        customerName: j['customerName'] as String,
        coins: (j['coins'] as num).toInt(),
        rupeeValue: j['rupeeValue'] as num,
      );
}

class OwnerPending {
  OwnerPending({required this.count, this.top});

  final int count;
  final OwnerPendingTop? top;

  factory OwnerPending.fromJson(Map<String, dynamic> j) => OwnerPending(
        count: (j['count'] as num?)?.toInt() ?? 0,
        top: j['top'] == null
            ? null
            : OwnerPendingTop.fromJson(j['top'] as Map<String, dynamic>),
      );
}

class OwnerActiveOffer {
  OwnerActiveOffer({
    required this.id,
    required this.title,
    required this.offerType,
    required this.endsAt,
  });

  final String id;
  final String title;
  final String offerType;
  final DateTime endsAt;

  factory OwnerActiveOffer.fromJson(Map<String, dynamic> j) => OwnerActiveOffer(
        id: j['id'] as String,
        title: j['title'] as String,
        offerType: j['offerType'] as String,
        endsAt: DateTime.parse(j['endsAt'] as String),
      );
}

class OwnerLeader {
  OwnerLeader({
    required this.rank,
    required this.customerName,
    required this.coins,
    required this.totalEarned,
    required this.tier,
    required this.visits,
    this.lastVisitDate,
  });

  final int rank;
  final String customerName;
  final int coins;
  final int totalEarned;
  final String tier;
  final int visits;
  final DateTime? lastVisitDate;

  factory OwnerLeader.fromJson(Map<String, dynamic> j) => OwnerLeader(
        rank: (j['rank'] as num).toInt(),
        customerName: j['customerName'] as String,
        coins: (j['coins'] as num).toInt(),
        totalEarned: (j['totalEarned'] as num).toInt(),
        tier: j['tier'] as String,
        visits: (j['visits'] as num).toInt(),
        lastVisitDate: j['lastVisitDate'] == null
            ? null
            : DateTime.parse(j['lastVisitDate'] as String),
      );
}

class OwnerDashboard {
  OwnerDashboard({
    this.store,
    required this.todayGmv,
    required this.todayVisits,
    required this.weekVisits,
    required this.weekTotal,
    required this.pendingRedemptions,
    this.activeOffer,
    required this.leaderboard,
  });

  final OwnerStoreRef? store;
  final num todayGmv;
  final int todayVisits;
  final List<OwnerVisitDay> weekVisits;
  final int weekTotal;
  final OwnerPending pendingRedemptions;
  final OwnerActiveOffer? activeOffer;
  final List<OwnerLeader> leaderboard;

  factory OwnerDashboard.fromJson(Map<String, dynamic> j) => OwnerDashboard(
        store: j['store'] == null
            ? null
            : OwnerStoreRef.fromJson(j['store'] as Map<String, dynamic>),
        todayGmv: (j['todayGmv'] as num?) ?? 0,
        todayVisits: (j['todayVisits'] as num?)?.toInt() ?? 0,
        weekVisits: ((j['weekVisits'] as List?) ?? const [])
            .map((e) => OwnerVisitDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        weekTotal: (j['weekTotal'] as num?)?.toInt() ?? 0,
        pendingRedemptions: OwnerPending.fromJson(
            (j['pendingRedemptions'] as Map<String, dynamic>?) ?? const {}),
        activeOffer: j['activeOffer'] == null
            ? null
            : OwnerActiveOffer.fromJson(
                j['activeOffer'] as Map<String, dynamic>),
        leaderboard: ((j['leaderboard'] as List?) ?? const [])
            .map((e) => OwnerLeader.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class OwnerApi {
  OwnerApi(this._client);
  final ApiClient _client;

  Future<OwnerDashboard> fetch() async {
    final data =
        await _client.get('/stores/dashboard') as Map<String, dynamic>;
    return OwnerDashboard.fromJson(data);
  }
}
