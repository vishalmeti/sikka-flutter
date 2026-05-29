import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sikka/core/api/api_exception.dart';
import 'package:sikka/features/onboarding/screens/login_screen.dart';

import '../support/harness.dart';

void main() {
  late FakeAuthApi api;

  setUp(() {
    initTestHarness();
    api = FakeAuthApi();
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    final authState = await makeAuthState();
    await tester.pumpWidget(
      wrapOnboarding(child: const LoginScreen(), authApi: api, authState: authState),
    );
    await tester.pump();
  }

  testWidgets('validates empty fields without calling the API', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Enter your username and password'), findsOneWidget);
    expect(api.loginCalls, 0);
  });

  testWidgets('logs a customer in and routes to the customer home', (tester) async {
    api.loginResult = authResult(role: 'customer', username: 'asha');
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), '  Asha  ');
    await tester.enterText(find.byType(TextField).at(1), 'secret6');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(api.loginCalls, 1);
    expect(api.lastUsername, 'asha'); // trimmed + lowercased before the call
    expect(api.lastPassword, 'secret6');
    expect(find.text('CUSTOMER STUB'), findsOneWidget);
  });

  testWidgets('routes an owner to the owner home', (tester) async {
    api.loginResult = authResult(role: 'owner', username: 'storeguy');
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), 'storeguy');
    await tester.enterText(find.byType(TextField).at(1), 'secret6');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('OWNER STUB'), findsOneWidget);
  });

  testWidgets('surfaces the API error message on a failed login', (tester) async {
    api.loginError = ApiException(
      statusCode: 401,
      message: 'Invalid username or password',
      code: 'UNAUTHORIZED',
    );
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), 'asha');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password'), findsOneWidget);
    expect(find.text('CUSTOMER STUB'), findsNothing);
  });

  testWidgets('"Create account" navigates to the register screen', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.textContaining('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('REGISTER STUB'), findsOneWidget);
  });
}
