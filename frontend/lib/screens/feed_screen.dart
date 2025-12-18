import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/feed_service.dart';

/// Revolutionary full-screen immersive dating card UI
/// Features: Glassmorphism, gesture-based interactions, smooth animations
/// One profile at a time, industry-leading experience
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _users = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;
  bool _isActioning = false;
  bool _showDetails = false;
  
  // Animation controllers
  late AnimationController _cardController;
  late AnimationController _likeController;
  late AnimationController _passController;
  late AnimationController _pulseController;
  
  // Drag state
  double _dragX = 0;
  double _dragY = 0;
  
  // Page controller for photo gallery
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadFeed();
  }

  void _initAnimations() {
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _passController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cardController.dispose();
    _likeController.dispose();
    _passController.dispose();
    _pulseController.dispose();
    super.dispose();
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

    setState(() => _isActioning = true);
    
    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
      final user = _users[_currentIndex];
      final result = await FeedService.interact(
        toUserId: user['id'],
        action: action,
      );

      // Animate card out
      if (action == 'like') {
        await _likeController.forward();
        _likeController.reset();
      } else {
        await _passController.forward();
        _passController.reset();
      }

      if (result['is_match'] == true && mounted) {
        _showMatchDialog(user);
      }

      setState(() {
        _currentIndex++;
        _isActioning = false;
        _dragX = 0;
        _dragY = 0;
        _showDetails = false;
        _currentPhotoIndex = 0;
      });

      if (_currentIndex >= _users.length - 3) {
        _loadFeed();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
      setState(() => _isActioning = false);
    }
  }

  void _showMatchDialog(Map<String, dynamic> user) {
    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Match Dialog',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: _buildMatchContent(user),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.elasticOut.transform(anim1.value),
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  Widget _buildMatchContent(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDB2777).withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'IT\'S A VIBE!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You and ${user['name']} want each other',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMatchButton('Later', Icons.schedule, () => Navigator.pop(context)),
              _buildMatchButton('Message', Icons.chat_bubble_rounded, () {
                Navigator.pop(context);
              }, isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchButton(String label, IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: isPrimary ? const Color(0xFFDB2777) : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? const Color(0xFFDB2777) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_users.isEmpty || _currentIndex >= _users.length) {
      return _buildEmptyState();
    }

    final user = _users[_currentIndex];
    return _buildProfileCard(user);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (_pulseController.value * 0.1),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.local_fire_department, color: Colors.white, size: 40),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Finding your vibes...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Lost',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            _buildGradientButton('Try Again', _loadFeed),
          ],
        ),
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
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.2),
                    const Color(0xFFDB2777).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text('🌙', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 32),
            const Text(
              'All caught up!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'New people are joining every minute.\nCome back soon for fresh vibes.',
              style: TextStyle(color: Colors.white.withOpacity(0.5), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildGradientButton('Refresh', _loadFeed),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDB2777).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> user) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dragX += details.delta.dx;
          _dragY += details.delta.dy;
        });
      },
      onPanEnd: (details) {
        if (_dragX > 100) {
          _handleAction('like');
        } else if (_dragX < -100) {
          _handleAction('pass');
        } else {
          setState(() {
            _dragX = 0;
            _dragY = 0;
          });
        }
      },
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _showDetails = !_showDetails);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_likeController, _passController]),
        builder: (context, child) {
          double offsetX = _dragX;
          double rotation = _dragX * 0.001;
          double opacity = 1.0;
          
          if (_likeController.isAnimating) {
            offsetX = _likeController.value * MediaQuery.of(context).size.width;
            opacity = 1 - _likeController.value;
          } else if (_passController.isAnimating) {
            offsetX = -_passController.value * MediaQuery.of(context).size.width;
            opacity = 1 - _passController.value;
          }
          
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..translate(offsetX, _dragY * 0.3)
              ..rotateZ(rotation),
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity,
              child: _buildCardContent(user),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(Map<String, dynamic> user) {
    final photos = user['photos'] as List? ?? [];
    final kinks = user['kinks'] as List? ?? [];
    final tags = user['tags'] as List? ?? [];
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Photo
        _buildPhotoBackground(photos),
        
        // Gradient Overlay
        _buildGradientOverlay(),
        
        // Like/Pass Indicators
        _buildSwipeIndicators(),
        
        // Content
        _showDetails 
          ? _buildExpandedDetails(user, kinks, tags)
          : _buildBasicInfo(user, kinks),
        
        // Action Buttons
        _buildActionButtons(),
        
        // Photo Navigation Dots
        if (photos.length > 1) _buildPhotoIndicators(photos),
      ],
    );
  }

  Widget _buildPhotoBackground(List photos) {
    if (photos.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF374151), Color(0xFF1F2937)],
          ),
        ),
        child: const Center(
          child: Text('🔥', style: TextStyle(fontSize: 100)),
        ),
      );
    }

    try {
      final photo = photos[_currentPhotoIndex % photos.length] as String;
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: MemoryImage(base64Decode(photo)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } catch (e) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
          ),
        ),
        child: const Center(
          child: Text('🔥', style: TextStyle(fontSize: 100)),
        ),
      );
    }
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.95),
          ],
          stops: const [0, 0.3, 0.5, 0.7, 1],
        ),
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    final likeOpacity = (_dragX / 100).clamp(0.0, 1.0);
    final passOpacity = (-_dragX / 100).clamp(0.0, 1.0);
    
    return Stack(
      children: [
        // LIKE indicator
        Positioned(
          top: 60,
          left: 30,
          child: Opacity(
            opacity: likeOpacity,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF22C55E), width: 4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VIBE ✓',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
        // PASS indicator
        Positioned(
          top: 60,
          right: 30,
          child: Opacity(
            opacity: passOpacity,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'NOPE',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(Map<String, dynamic> user, List kinks) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Age
          Row(
            children: [
              Expanded(
                child: Text(
                  '${user['name'] ?? 'Anonymous'}${user['age'] != null ? ', ${user['age']}' : ''}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 20, color: Colors.black)],
                  ),
                ),
              ),
              if (user['is_verified'] == true)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.verified, color: Colors.white, size: 18),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Quick Info Row
          Row(
            children: [
              if (user['height'] != null) _buildQuickInfo(Icons.straighten, user['height']),
              if (user['body_type'] != null) _buildQuickInfo(Icons.accessibility_new, user['body_type']),
              if (user['relationship_type'] != null) _buildQuickInfo(Icons.favorite_border, user['relationship_type']),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Bio
          if (user['bio'] != null && user['bio'].toString().isNotEmpty)
            Text(
              user['bio'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          
          const SizedBox(height: 16),
          
          // Kinks Preview
          if (kinks.isNotEmpty) ...[
            Row(
              children: [
                const Text('🔥 ', style: TextStyle(fontSize: 14)),
                Text(
                  'KINKS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFDB2777),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kinks.take(4).map<Widget>((kink) => _buildKinkChip(kink.toString())).toList(),
            ),
          ],
          
          // Tap hint
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Tap for more details',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildKinkChip(String kink) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFDB2777).withOpacity(0.3),
            const Color(0xFF7C3AED).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDB2777).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        kink,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(Map<String, dynamic> user, List kinks, List tags) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.95),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button hint
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Name
              Text(
                '${user['name'] ?? 'Anonymous'}${user['age'] != null ? ', ${user['age']}' : ''}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Bio
              if (user['bio'] != null)
                Text(
                  user['bio'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              
              const SizedBox(height: 30),
              
              // Lifestyle Section
              _buildSectionTitle('LIFESTYLE'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (user['height'] != null) _buildLifestyleItem('📏', 'Height', user['height']),
                  if (user['body_type'] != null) _buildLifestyleItem('💪', 'Body', user['body_type']),
                  if (user['drinking'] != null) _buildLifestyleItem('🍷', 'Drinks', user['drinking']),
                  if (user['smoking'] != null) _buildLifestyleItem('🚬', 'Smokes', user['smoking']),
                  if (user['relationship_type'] != null) _buildLifestyleItem('💕', 'Looking for', user['relationship_type']),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Kinks Section
              if (kinks.isNotEmpty) ...[
                _buildSectionTitle('🔥 KINKS & TURN-ONS'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: kinks.map<Widget>((kink) => _buildKinkChip(kink.toString())).toList(),
                ),
                const SizedBox(height: 30),
              ],
              
              // Interests Section
              if (tags.isNotEmpty) ...[
                _buildSectionTitle('INTERESTS'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: tags.map<Widget>((tag) => _buildInterestChip(tag.toString())).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFFDB2777),
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildLifestyleItem(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$interest',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPhotoIndicators(List photos) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        children: List.generate(
          photos.length,
          (index) => Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index == _currentPhotoIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pass Button
          _buildCircleButton(
            icon: Icons.close_rounded,
            size: 60,
            iconSize: 32,
            colors: [Colors.redAccent.withOpacity(0.8), Colors.red],
            onTap: () => _handleAction('pass'),
          ),
          
          const SizedBox(width: 24),
          
          // Super Like (future feature)
          _buildCircleButton(
            icon: Icons.star_rounded,
            size: 50,
            iconSize: 26,
            colors: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
            onTap: () {
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Super Like coming soon! 💎'),
                  backgroundColor: Color(0xFF3B82F6),
                ),
              );
            },
          ),
          
          const SizedBox(width: 24),
          
          // Like Button
          _buildCircleButton(
            icon: Icons.favorite_rounded,
            size: 70,
            iconSize: 38,
            colors: [const Color(0xFF22C55E), const Color(0xFF16A34A)],
            onTap: () => _handleAction('like'),
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required double size,
    required double iconSize,
    required List<Color> colors,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: _isActioning ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.4),
              blurRadius: isPrimary ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
