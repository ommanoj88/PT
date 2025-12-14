import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/feed_service.dart';
import 'login_screen.dart';
import 'feed_screen.dart';
import 'matches_screen.dart';
import 'wallet_screen.dart';
import 'profile_name_gender_screen.dart';

/// Main home screen with bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isDiceRolling = false;

  final List<Widget> _screens = [
    const FeedScreen(),
    const MatchesScreen(),
    const WalletScreen(),
  ];

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleDiceRoll() async {
    if (_isDiceRolling) return;

    setState(() {
      _isDiceRolling = true;
    });

    try {
      final user = await FeedService.rollDice();

      if (mounted) {
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No users available right now')),
          );
        } else {
          _showDiceResult(user);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDiceRolling = false;
        });
      }
    }
  }

  void _showDiceResult(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF0F172A),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.casino,
              color: Color(0xFFD946EF),
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              '🎲 Dice Result!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // User info
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF6B21A8),
              child: Text(
                (user['name'] as String? ?? '?')[0].toUpperCase(),
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${user['name'] ?? 'Unknown'}${user['age'] != null ? ', ${user['age']}' : ''}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (user['bio'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  user['bio'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Pass'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Like and maybe start chat
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text('Like'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeCheck'),
        backgroundColor: const Color(0xFF6B21A8),
        actions: [
          // Dice button
          IconButton(
            onPressed: _isDiceRolling ? null : _handleDiceRoll,
            icon: _isDiceRolling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.casino),
            tooltip: 'Roll the Dice',
          ),
        ],
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
                    Color(0xFF6B21A8),
                    Color(0xFF1E1B4B),
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
              title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileNameGenderScreen()),
                );
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
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF0F172A),
        selectedItemColor: const Color(0xFFD946EF),
        unselectedItemColor: const Color(0xFFA78BFA),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}
