import 'package:cobi_paint_mobile/data/builtin_images.dart';
import 'package:cobi_paint_mobile/models/category.dart';
import 'package:cobi_paint_mobile/providers/app_provider.dart';
import 'package:cobi_paint_mobile/screens/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final animals = Category.getDefaultCategories().firstWhere((c) => c.id == 'animals');

  Future<void> pumpCategory(WidgetTester tester) async {
    // Built-in pages need no storage, so the provider works without init()
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: MaterialApp(home: CategoryScreen(category: animals)),
      ),
    );
  }

  testWidgets('shows the built-in pages of the category', (tester) async {
    await pumpCategory(tester);

    final firstPage = builtInImages.firstWhere((page) => page.category == 'animals');
    expect(find.text(animals.name), findsOneWidget);
    expect(find.text(firstPage.name), findsOneWidget);
  });

  testWidgets('page tiles meet the minimum tap target size', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCategory(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    handle.dispose();
  });
}
