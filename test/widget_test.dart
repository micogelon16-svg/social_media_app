import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_media_app/screens/auth_gate.dart';

// B Munezero Ami Christian
// 2401000232
void main() {
  testWidgets('AuthGate renders within MaterialApp context', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthGate(),
      ),
    );

    expect(find.byType(AuthGate), findsOneWidget);
  });
}