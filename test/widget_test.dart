import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projet/main.dart';

void main() {
  testWidgets('Onboarding page displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MedPassApp());

    expect(find.text('Travel Light with Medpass'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('Login button navigates to login page', (WidgetTester tester) async {
    await tester.pumpWidget(const MedPassApp());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('Register button navigates to register page', (WidgetTester tester) async {
    await tester.pumpWidget(const MedPassApp());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Register'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
  });
}
