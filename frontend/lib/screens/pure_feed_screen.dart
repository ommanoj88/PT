import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/feed_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Pure-style feed screen with grid view of live users.
/// Features: Go Live button, time-limited profiles, direct chat requests.
class PureFeedScreen extends StatefulWidget {
  const PureFeedScreen({super.key});

  @override
  State<PureFeedScreen> createState() => _PureFeedScreenState();
}

class _PureFeedScreenState extends State<PureFeedScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;
  bool _isLive = false;
  DateTime? _liveUntil;
  bool _isGoingLive = false;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _loadProfile();
    _loadFeed();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.getProfile();
      setState(() {
        _isLive = profile['is_live'] == true;
        if (profile['live_until'] != null) {
          _liveUntil = DateTime.parse(profile['live_until']);
          // Check if still live
          if (_liveUntil!.isBefore(DateTime.now())) {
            _isLive = false;
            _liveUntil = null;
          }
        }
      });
    } catch (e) {
      // Ignore profile load errors
    }
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoLive() async {
    if (_isGoingLive) return;
    
    HapticFeedback.mediumImpact();
    
    setState(() => _isGoingLive = true);

    try {
      final result = await ProfileService.goLive(durationHours: 1);
      setState(() {
        _isLive = result['is_live'] == true;
        if (result['live_until'] != null) {
          _liveUntil = DateTime.parse(result['live_until']);
        }
        _isGoingLive = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔴 You are now LIVE! Others can see you.'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
      
      // Reload feed to see others who are live
      _loadFeed();
    } catch (e) {
      setState(() => _isGoingLive = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoOffline() async {
    HapticFeedback.lightImpact();

    try {
      await ProfileService.goOffline();
      setState(() {
        _isLive = false;
        _liveUntil = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are now offline'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendChatRequest(Map<String, dynamic> user) async {
    HapticFeedback.mediumImpact();

    try {
      await FeedService.sendChatRequest(toUserId: user['id']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request sent to ${user['name']}!'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
      
      // Remove user from list
      setState(() {
        _users.removeWhere((u) => u['id'] == user['id']);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Go Live Banner
            _buildGoLiveBanner(),
            
            // Main Content
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildGoLiveBanner() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _isLive 
          ? const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)])
          : const LinearGradient(colors: [Color(0xFF374151), Color(0xFF1F2937)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _isLive ? [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (_isLive) ...[
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5 + _pulseController.value * 0.5),
                            blurRadius: 8 + _pulseController.value * 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                if (_liveUntil != null)
                  Text(
                    _getRemainingTime(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
              ] else ...[
                const Icon(Icons.visibility_off, color: Colors.white54, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'You are invisible. Go live to be seen!',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _isLive 
              ? OutlinedButton.icon(
                  onPressed: _handleGoOffline,
                  icon: const Icon(Icons.visibility_off, color: Colors.white),
                  label: const Text('Go Offline', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: _isGoingLive ? null : _handleGoLive,
                  icon: _isGoingLive 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.sensors, color: Colors.white),
                  label: Text(
                    _isGoingLive ? 'Going Live...' : 'Go Live (1 hour)',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  String _getRemainingTime() {
    if (_liveUntil == null) return '';
    final remaining = _liveUntil!.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    
    final minutes = remaining.inMinutes;
    if (minutes >= 60) {
      return '${remaining.inHours}h ${minutes % 60}m left';
    }
    return '${minutes}m left';
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_users.isEmpty) {
      return _buildEmptyState();
    }

    return _buildUserGrid();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFEF4444)),
          SizedBox(height: 16),
          Text(
            'Finding people near you...',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white54, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Could not load users',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadFeed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👀', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            const Text(
              'No one is live right now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Be the first to go live and wait for others!',
              style: TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadFeed,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Refresh', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGrid() {
    return RefreshIndicator(
      onRefresh: _loadFeed,
      color: const Color(0xFFEF4444),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return _buildUserCard(_users[index]);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final photos = user['photos'] as List? ?? [];
    final minutesRemaining = user['minutes_remaining'] as int?;

    return GestureDetector(
      onTap: () => _showUserProfile(user),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: photos.isNotEmpty
                ? Image.memory(
                    base64Decode(photos[0]),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: const Color(0xFF374151),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white30, size: 48),
                    ),
                  ),
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            
            // Live indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      minutesRemaining != null ? '${minutesRemaining}m' : 'LIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // User info
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user['name'] ?? 'Anonymous'}${user['age'] != null ? ', ${user['age']}' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user['bio'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user['bio'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserProfile(Map<String, dynamic> user) {
    final photos = user['photos'] as List? ?? [];
    final kinks = user['kinks'] as List? ?? [];

    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo
                    if (photos.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 0.8,
                          child: Image.memory(
                            base64Decode(photos[0]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xFF374151),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: Colors.white30, size: 80),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Name and age
                    Text(
                      '${user['name'] ?? 'Anonymous'}${user['age'] != null ? ', ${user['age']}' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Bio
                    if (user['bio'] != null)
                      Text(
                        user['bio'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Kinks
                    if (kinks.isNotEmpty) ...[
                      const Text(
                        'INTERESTS',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: kinks.map<Widget>((kink) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                            ),
                            child: Text(
                              kink.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  // Skip button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Skip', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Chat button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _sendChatRequest(user);
                      },
                      icon: const Icon(Icons.chat_bubble, color: Colors.white),
                      label: const Text(
                        'Request Chat',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
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
}
