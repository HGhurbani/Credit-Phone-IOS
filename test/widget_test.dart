import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:creditphoneqa/providers/cart_provider.dart';
import 'package:creditphoneqa/providers/locale_provider.dart';
import 'package:creditphoneqa/providers/user_provider.dart';
import 'package:creditphoneqa/screens/settings_screen.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
          ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
          ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
