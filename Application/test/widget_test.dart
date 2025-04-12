// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:application/main.dart';
import 'package:application/providers/notification_provider.dart';

void main() {
  testWidgets('App should build without crashing', (WidgetTester tester) async {
    // Create a mock NotificationProvider
    final mockNotificationProvider = NotificationProvider();

    // Build our app with required providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationProvider>.value(
            value: mockNotificationProvider,
          ),
        ],
        child: MyApp(),
      ),
    );

    // Verify the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App should have correct theme', (WidgetTester tester) async {
    // Create a mock NotificationProvider
    final mockNotificationProvider = NotificationProvider();

    // Build our app with required providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationProvider>.value(
            value: mockNotificationProvider,
          ),
        ],
        child: MyApp(),
      ),
    );

    // Find the MaterialApp widget
    final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

    // Verify theme properties
    expect(materialApp.theme != null, true);
    expect(materialApp.debugShowCheckedModeBanner, false);
    expect(materialApp.title, 'Club Management');
  });
}
