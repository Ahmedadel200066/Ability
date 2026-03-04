import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_driver_app/main.dart';

void main() {
  testWidgets('Elite App UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EliteApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
