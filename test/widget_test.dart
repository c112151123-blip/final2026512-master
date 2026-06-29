// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final2026512/main.dart';

void main() {
  testWidgets('Steam search page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Steam 跨區與序號比價'), findsOneWidget);
    expect(find.text('搜尋'), findsOneWidget);
    expect(find.text('請輸入條件後按搜尋'), findsOneWidget);
  });
}
