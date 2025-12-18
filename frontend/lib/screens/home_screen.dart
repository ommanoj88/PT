import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/feed_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
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
        FadeSlidePageRoute(page: const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleDiceRoll() async {
    if (_isDiceRolling) return;
    
    HapticFeedback.mediumImpact();

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusXLarge),
            topRight: Radius.circular(AppTheme.radiusXLarge),
          ),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacing12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Icon(
              Icons.casino,
              color: colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              '🎲 Dice Result!',
              style: textTheme.headlineLarge,
            ),
            const SizedBox(height: AppTheme.spacing24),
            // User info
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.transparent,
                child: Text(
                  (user['name'] as String? ?? '?')[0].toUpperCase(),
                  style: textTheme.displayMedium,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              '${user['name'] ?? 'Unknown'}${user['age'] != null ? ', ${user['age']}' : ''}',
              style: textTheme.displaySmall,
            ),
            const SizedBox(height: AppTheme.spacing8),
            if (user['bio'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
                child: Text(
                  user['bio'],
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PremiumIconButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.pop(context),
                    size: 60,
                    iconSize: 32,
                    gradientColors: [colorScheme.error, colorScheme.error.withOpacity(0.7)],
                  ),
                  PremiumIconButton(
                    icon: Icons.favorite_rounded,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      // TODO: Like and maybe start chat
                    },
                    size: 70,
                    iconSize: 36,
                    isPrimary: true,
                    gradientColors: [AppTheme.success, AppTheme.success.withOpacity(0.7)],
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('VibeCheck', style: textTheme.headlineSmall),
        backgroundColor: colorScheme.secondaryContainer,
        actions: [
          // Dice button
          IconButton(
            onPressed: _isDiceRolling ? null : _handleDiceRoll,
            icon: _isDiceRolling
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: colorScheme.onSurface,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.casino),
            tooltip: 'Roll the Dice',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: colorScheme.secondaryContainer,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'VibeCheck',
                    style: textTheme.headlineLarge,
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
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outline,
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
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.secondary,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'Matches',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Wallet',
            ),
          ],
        ),
      ),
    );
  }
}
