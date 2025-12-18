import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/feed_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'chat_room_screen.dart';

/// Screen showing list of matches for chat.
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final matches = await FeedService.getMatches();
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: _buildBody(colorScheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 48),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Error loading matches',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            PremiumButton.primary(
              label: 'Retry',
              onPressed: _loadMatches,
            ),
          ],
        ),
      );
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentPurple.withOpacity(0.3),
                    AppTheme.accentFuchsia.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: colorScheme.secondary,
                size: 64,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              'No matches yet',
              style: textTheme.headlineLarge,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Start exploring to find your match!',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      color: colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return AnimatedListItem(
            index: index,
            child: _buildMatchTile(match, colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildMatchTile(Map<String, dynamic> match, ColorScheme colorScheme) {
    final user = match['user'] as Map<String, dynamic>;
    final photos = user['photos'] as List? ?? [];
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: const EdgeInsets.all(AppTheme.spacing12),
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          FadeSlidePageRoute(
            page: ChatRoomScreen(
              matchId: match['match_id'],
              userName: user['name'] ?? 'Unknown',
              userPhoto: photos.isNotEmpty ? photos[0] : null,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: colorScheme.surface,
              backgroundImage: photos.isNotEmpty
                  ? MemoryImage(base64Decode(photos[0]))
                  : null,
              child: photos.isEmpty
                  ? Icon(Icons.person, color: colorScheme.secondary)
                  : null,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Unknown',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  user['bio'] ?? 'Tap to start chatting',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}
