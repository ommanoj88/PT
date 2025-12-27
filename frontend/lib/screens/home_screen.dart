import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/feed_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'login_screen.dart';
import 'pure_feed_screen.dart';
import 'requests_screen.dart';
import 'wallet_screen.dart';
import 'profile_name_gender_screen.dart';

/// Main home screen with bottom navigation - Pure style.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PureFeedScreen(),
    const RequestsScreen(),
    const WalletScreen(),
  ];

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        FadeSlidePageRoute(page: const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pure', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1A1A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.sensors,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pure',
                    style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Privacy-first dating',
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: colorScheme.secondary),
              title: Text('Edit Profile', style: textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  FadeSlidePageRoute(page: const ProfileNameGenderScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: colorScheme.secondary),
              title: Text('Settings', style: textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
              },
            ),
            Divider(color: colorScheme.secondary),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text('Logout', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: AppTheme.durationMedium,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFFEF4444),
          unselectedItemColor: Colors.white54,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Browse',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Credits',
            ),
          ],
        ),
      ),
    );
  }
}
