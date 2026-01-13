import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cobi_paint_mobile/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CobiPaintApp());

    // Verify that splash screen elements are present
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
