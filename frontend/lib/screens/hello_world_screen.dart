import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

/// Home screen with drawer for logout functionality.
class HelloWorldScreen extends StatelessWidget {
  const HelloWorldScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeCheck'),
        backgroundColor: const Color(0xFF6B21A8), // Deep purple - nightlife theme
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E1B4B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6B21A8), // Deep purple
                    Color(0xFF1E1B4B), // Dark indigo
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 48,
                    color: Color(0xFFD946EF),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'VibeCheck',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFFA78BFA)),
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFFA78BFA)),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
              },
            ),
            const Divider(color: Color(0xFFA78BFA)),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
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
