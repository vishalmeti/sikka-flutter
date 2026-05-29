import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sikka/core/api/api_exception.dart';
import 'package:sikka/features/onboarding/screens/register_screen.dart';

import '../support/harness.dart';

void main() {
  late FakeAuthApi api;

  setUp(() {
    initTestHarness();
    api = FakeAuthApi();
  });

  Future<void> pumpRegister(WidgetTester tester, {String? pendingRole}) async {
    final authState = await makeAuthState(pendingRole: pendingRole);
    await tester.pumpWidget(
      wrapOnboarding(child: const RegisterScreen(), authApi: api, authState: authState),
    );
    await tester.pump();
  }

  Future<void> fillForm(
    WidgetTester tester, {
    required String name,
    required String username,
    required String password,
  }) async {
    await tester.enterText(find.byType(TextField).at(0), name);
    await tester.enterText(find.byType(TextField).at(1), username);
    await tester.enterText(find.byType(TextField).at(2), password);
  }

  testWidgets('rejects a too-short name before calling the API', (tester) async {
    await pumpRegister(tester);

    await fillForm(tester, name: 'A', username: 'asha', password: 'secret6');
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Enter your name (at least 2 characters)'), findsOneWidget);
    expect(api.registerCalls, 0);
  });

  testWidgets('rejects an invalid username', (tester) async {
    await pumpRegister(tester);

    await fillForm(tester, name: 'Asha', username: 'ab', password: 'secret6');
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Username must be 3–20 letters, numbers or _'), findsOneWidget);
    expect(api.registerCalls, 0);
  });

  testWidgets('rejects a short password', (tester) async {
    await pumpRegister(tester);

    await fillForm(tester, name: 'Asha', username: 'asha', password: '123');
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(api.registerCalls, 0);
  });

  testWidgets('registers a shopper with normalized args and routes home', (tester) async {
    api.registerResult = authResult(role: 'customer', username: 'asha', name: 'Asha');
    await pumpRegister(tester);

    await fillForm(tester, name: '  Asha  ', username: 'ASHA', password: 'secret6');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(api.registerCalls, 1);
    expect(api.lastUsername, 'asha'); // lowercased
    expect(api.lastName, 'Asha'); // trimmed
    expect(api.lastPassword, 'secret6');
    expect(api.lastRole, 'customer');
    expect(find.text('CUSTOMER STUB'), findsOneWidget);
  });

  testWidgets('shows the owner chip and registers with role owner', (tester) async {
    api.registerResult = authResult(role: 'owner', username: 'storeguy', name: 'Store Guy');
    await pumpRegister(tester, pendingRole: 'owner');

    expect(find.text('Signing up as Store owner'), findsOneWidget);

    await fillForm(tester, name: 'Store Guy', username: 'storeguy', password: 'secret6');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(api.lastRole, 'owner');
    expect(find.text('OWNER STUB'), findsOneWidget);
  });

  testWidgets('surfaces a 409 conflict message from the API', (tester) async {
    api.registerError = ApiException(
      statusCode: 409,
      message: 'Username already taken',
      code: 'CONFLICT',
    );
    await pumpRegister(tester);

    await fillForm(tester, name: 'Asha', username: 'asha', password: 'secret6');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Username already taken'), findsOneWidget);
    expect(find.text('CUSTOMER STUB'), findsNothing);
  });
}
