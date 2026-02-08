import 'package:flutter/material.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const ChessTrainerApp());
}

/// Main application widget for Chess Trainer
class ChessTrainerApp extends StatelessWidget {
  const ChessTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SearchScreen(),
    );
  }
}
