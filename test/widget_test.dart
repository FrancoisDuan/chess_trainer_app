// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_trainer_app/main.dart';

void main() {
  testWidgets('Chess Trainer app starts with search screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChessTrainerApp());

    // Verify that the search screen is displayed.
    expect(find.text('Chess Trainer'), findsOneWidget);
    expect(find.text('Analyze Your Chess Games'), findsOneWidget);
    expect(find.text('Chess.com Username'), findsOneWidget);
    expect(find.text('Analyze'), findsOneWidget);
  });

  testWidgets('Search screen shows error for empty username', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChessTrainerApp());

    // Tap the Analyze button without entering username.
    await tester.tap(find.text('Analyze'));
    await tester.pump();

    // Verify that an error message is shown.
    expect(find.text('Please enter a username'), findsOneWidget);
  });
}
