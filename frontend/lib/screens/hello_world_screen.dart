import 'package:flutter/material.dart';

/// Hello World screen to verify the Flutter setup is working correctly.
class HelloWorldScreen extends StatelessWidget {
  const HelloWorldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeCheck'),
        backgroundColor: const Color(0xFF6B21A8), // Deep purple - nightlife theme
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1B4B), // Dark indigo
              Color(0xFF0F172A), // Dark blue
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: 80,
                color: Color(0xFFD946EF), // Fuchsia pink
              ),
              SizedBox(height: 24),
              Text(
                'Welcome to VibeCheck',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'The Privacy-First High-Intent Dating App',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFA78BFA), // Light purple
                ),
              ),
              SizedBox(height: 48),
              Text(
                '🎲 Roll the Dice',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
