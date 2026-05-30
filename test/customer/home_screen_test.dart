import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sikka/core/api/api_exception.dart';
import 'package:sikka/core/api/dashboard_api.dart';
import 'package:sikka/features/customer/state/customer_home_store.dart';

import '../support/harness.dart';

void main() {
  late FakeDashboardApi api;

  setUp(() {
    initTestHarness();
    api = FakeDashboardApi();
  });

  // The home screen schedules one-shot tween animations on mount; explicit
  // pump()s give them just enough time to surface their initial frame without
  // waiting for the full duration.

  testWidgets('shows a loading spinner while the dashboard is in flight', (tester) async {
    api.gate = Completer<CustomerDashboard>(); // never completed → stays loading
    final store = CustomerHomeStore(api);

    await tester.pumpWidget(wrapHome(store: store));
    await tester.pump(); // postFrameCallback fires load()
    await tester.pump(); // rebuild reflects the loading state

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders the user name, stores and activity once loaded', (tester) async {
    api.result = dashboard(
      userName: 'Vishal',
      stores: [
        DashboardStore(
          id: 's1',
          name: 'Sri Lakshmi Stores',
          coins: 540,
          totalEarned: 620,
          tier: 'gold',
          tierProgress: 0.8,
          visits: 4,
        ),
        DashboardStore(
          id: 's2',
          name: 'Anand Kirana',
          coins: 180,
          totalEarned: 300,
          tier: 'silver',
          tierProgress: 0.3,
          visits: 2,
        ),
      ],
    );
    final store = CustomerHomeStore(api);
    await store.load(); // resolves immediately; screen builds with data present

    await tester.pumpWidget(wrapHome(store: store));
    await tester.pump();

    // The hero label renders the name inside "Vishal • All stores".
    expect(find.textContaining('Vishal'), findsOneWidget);
    // Appears in its store card and in the (default) activity row for that store.
    expect(find.text('Sri Lakshmi Stores'), findsWidgets);
    expect(find.text('Anand Kirana'), findsOneWidget);
  });

  testWidgets('shows empty hints when there are no stores or activity', (tester) async {
    api.result = dashboard(stores: const [], activity: const []);
    final store = CustomerHomeStore(api);
    await store.load();

    await tester.pumpWidget(wrapHome(store: store));
    await tester.pump();

    expect(find.text('No stores yet. Scan a store QR to start earning.'), findsOneWidget);
    expect(find.text('No activity yet.'), findsOneWidget);
  });

  testWidgets('shows the error state and recovers via Retry', (tester) async {
    api.failTimes = 1;
    api.error = ApiException(statusCode: 500, message: 'Network error');
    final store = CustomerHomeStore(api);

    // Let the screen's own mount-load drive the (failing) fetch. Pre-loading
    // here would leave _data null, so the mount-load would fetch a 2nd time.
    await tester.pumpWidget(wrapHome(store: store));
    await tester.pump(); // postFrameCallback → load() → fetch throws
    await tester.pump(); // rebuild error UI

    expect(find.text('Network error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Second fetch succeeds (failTimes already consumed).
    api.result = dashboard(userName: 'Vishal');
    await tester.tap(find.text('Retry'));
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    expect(find.text('Network error'), findsNothing);
    expect(find.textContaining('Vishal'), findsOneWidget);
  });
}
