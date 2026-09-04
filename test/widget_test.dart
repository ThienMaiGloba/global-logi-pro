import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_logi_pro/main.dart';

void main() {
  testWidgets('Global Logi Pro structural test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
