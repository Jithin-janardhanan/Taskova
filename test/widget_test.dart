import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskova/language_provider.dart';
import 'package:taskova/language_selection_screen.dart';
import 'package:taskova/login.dart';
import 'package:taskova/main.dart';

void main() {
  testWidgets('App shows LanguageSelectionScreen when language not selected', 
      (WidgetTester tester) async {
    // Mock hasSelectedLanguage as false
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppLanguage(),
        child: const MyApp(hasSelectedLanguage: false),
      ),
    );

    // Verify that LanguageSelectionScreen is shown
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    expect(find.byType(Login), findsNothing);
  });

  testWidgets('App shows Login when language is already selected', 
      (WidgetTester tester) async {
    // Mock hasSelectedLanguage as true
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppLanguage(),
        child: const MyApp(hasSelectedLanguage: true),
      ),
    );

    // Verify that Login screen is shown
    expect(find.byType(Login), findsOneWidget);
    expect(find.byType(LanguageSelectionScreen), findsNothing);
  });
}