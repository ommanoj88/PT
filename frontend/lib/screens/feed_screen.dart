import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/feed_service.dart';

/// Main feed screen with vertical scroll card stack.
/// Displays potential matches with "Vibe Check" buttons.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> _users = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;
  bool _isActioning = false;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await FeedService.getFeed();
      setState(() {
        _users = users;
        _currentIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAction(String action) async {
    if (_currentIndex >= _users.length || _isActioning) return;

    setState(() {
      _isActioning = true;
    });

    try {
      final user = _users[_currentIndex];
      final result = await FeedService.interact(
        toUserId: user['id'],
        action: action,
      );

      if (result['is_match'] == true && mounted) {
        _showMatchDialog(user);
      }

      setState(() {
        _currentIndex++;
        _isActioning = false;
      });

      // Load more users if running low
      if (_currentIndex >= _users.length - 2) {
        _loadFeed();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      setState(() {
        _isActioning = false;
      });
    }
  }

  void _showMatchDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              color: Color(0xFFD946EF),
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              "It's a Match!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You and ${user['name']} liked each other!',
              style: const TextStyle(color: Color(0xFFA78BFA)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Exploring',
              style: TextStyle(color: Color(0xFFA78BFA)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to chat
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD946EF),
            ),
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD946EF)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading feed',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD946EF),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty || _currentIndex >= _users.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_search,
              color: Color(0xFFA78BFA),
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'No more profiles',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new people!',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFeed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD946EF),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final user = _users[_currentIndex];
    return _buildUserCard(user);
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Stack(
      children: [
        // User profile card
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo
                _buildPhoto(user),
                // Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${user['name'] ?? 'Unknown'}${user['age'] != null ? ', ${user['age']}' : ''}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (user['is_verified'] == true)
                            const Icon(
                              Icons.verified,
                              color: Color(0xFF3B82F6),
                              size: 24,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (user['bio'] != null && user['bio'].toString().isNotEmpty)
                        Text(
                          user['bio'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (user['tags'] != null && (user['tags'] as List).isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (user['tags'] as List).map<Widget>((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD946EF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFD946EF).withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                tag.toString(),
                                style: const TextStyle(
                                  color: Color(0xFFA78BFA),
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Vibe Check Buttons
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Pass button (Red X)
              _buildActionButton(
                icon: Icons.close,
                color: Colors.redAccent,
                onPressed: _isActioning ? null : () => _handleAction('pass'),
              ),
              // Like button (Green Check)
              _buildActionButton(
                icon: Icons.favorite,
                color: const Color(0xFF22C55E),
                onPressed: _isActioning ? null : () => _handleAction('like'),
                isLarge: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto(Map<String, dynamic> user) {
    final photos = user['photos'] as List? ?? [];
    
    if (photos.isEmpty) {
      return Container(
        height: 400,
        color: const Color(0xFF374151),
        child: const Center(
          child: Icon(
            Icons.person,
            size: 120,
            color: Color(0xFFA78BFA),
          ),
        ),
      );
    }

    // First photo (Base64 encoded)
    final photo = photos[0] as String;
    
    return Container(
      height: 400,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: MemoryImage(base64Decode(photo)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isLarge = false,
  }) {
    final size = isLarge ? 70.0 : 56.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: isLarge ? 36 : 28),
        onPressed: onPressed,
      ),
    );
  }
}
