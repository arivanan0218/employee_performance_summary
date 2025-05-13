// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Import your actual app's main.dart - update the path if necessary
import 'package:employee_performance_summary/main.dart';

// Import the service provider
import 'package:employee_performance_summary/services/employee_provider.dart';

void main() {
  testWidgets('Basic app structure test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => EmployeeProvider(),
        child: const MyApp(),
      ),
    );

    // Verify that the dashboard screen appears
    expect(find.text('Welcome to Employee Performance'), findsOneWidget);

    // Verify that the upload button exists
    expect(find.text('Generate AI Summaries'), findsOneWidget);

    // Verify that the app bar is rendered
    expect(find.byType(AppBar), findsOneWidget);
  });
}
