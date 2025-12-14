import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/feed_service.dart';
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
              'Error loading matches',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMatches,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD946EF),
              ),
              child: const Text('Retry'),
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
            const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFFA78BFA),
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'No matches yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start exploring to find your match!',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      color: const Color(0xFFD946EF),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return _buildMatchTile(match);
        },
      ),
    );
  }

  Widget _buildMatchTile(Map<String, dynamic> match) {
    final user = match['user'] as Map<String, dynamic>;
    final photos = user['photos'] as List? ?? [];

    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF6B21A8),
          backgroundImage: photos.isNotEmpty
              ? MemoryImage(base64Decode(photos[0]))
              : null,
          child: photos.isEmpty
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        title: Text(
          user['name'] ?? 'Unknown',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          user['bio'] ?? 'Tap to start chatting',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFFA78BFA),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                matchId: match['match_id'],
                userName: user['name'] ?? 'Unknown',
                userPhoto: photos.isNotEmpty ? photos[0] : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
