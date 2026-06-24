import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progressive_rollout_demo/main.dart';

void main() {
  testWidgets('MyApp builds correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(groupNumber: 10));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Group number: 10'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
