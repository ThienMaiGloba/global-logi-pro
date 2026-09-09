import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_logi_pro/main.dart';

void main() {
  testWidgets('Driver screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GlobalLogiApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
