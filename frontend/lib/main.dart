import 'package:flutter/material.dart';
import 'screens/hello_world_screen.dart';

void main() {
  runApp(const VibeCheckApp());
}

/// Main application widget for VibeCheck.
class VibeCheckApp extends StatelessWidget {
  const VibeCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeCheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B21A8), // Deep purple
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HelloWorldScreen(),
    );
  }
}
