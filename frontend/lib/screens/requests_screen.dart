import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/request_service.dart';
import '../services/feed_service.dart';
import '../theme/app_theme.dart';
import 'chat_room_screen.dart';

/// Pure-style requests screen showing incoming and sent chat requests.
class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _incomingRequests = [];
  List<Map<String, dynamic>> _sentRequests = [];
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;
  String? _error;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        RequestService.getRequests(),
        RequestService.getSentRequests(),
        FeedService.getMatches(),
      ]);

      setState(() {
        _incomingRequests = results[0];
        _sentRequests = results[1];
        _matches = results[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    HapticFeedback.mediumImpact();

    try {
      final result = await RequestService.acceptRequest(request['id']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted! You can now chat.'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );

        // Navigate to chat if match_id is returned
        if (result['match_id'] != null) {
          final fromUser = request['from_user'] as Map<String, dynamic>;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                matchId: result['match_id'],
                userName: fromUser['name'] ?? 'Unknown',
                userPhoto: (fromUser['photos'] as List?)?.isNotEmpty == true
                    ? fromUser['photos'][0]
                    : null,
              ),
            ),
          );
        }
      }
      
      _loadData();
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

  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    HapticFeedback.lightImpact();

    try {
      await RequestService.rejectRequest(request['id']);
      
      setState(() {
        _incomingRequests.removeWhere((r) => r['id'] == request['id']);
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
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(text: 'Requests (${_incomingRequests.length})'),
                Tab(text: 'Sent (${_sentRequests.length})'),
                Tab(text: 'Chats (${_matches.length})'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIncomingRequestsList(),
                _buildSentRequestsList(),
                _buildMatchesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequestsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF4444)),
      );
    }

    if (_incomingRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox,
        title: 'No requests yet',
        subtitle: 'When someone wants to chat with you, their request will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFEF4444),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _incomingRequests.length,
        itemBuilder: (context, index) {
          return _buildIncomingRequestCard(_incomingRequests[index]);
        },
      ),
    );
  }

  Widget _buildIncomingRequestCard(Map<String, dynamic> request) {
    final fromUser = request['from_user'] as Map<String, dynamic>;
    final photos = fromUser['photos'] as List? ?? [];
    final minutesRemaining = request['minutes_remaining'] as int?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with timer
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF374151),
                backgroundImage: photos.isNotEmpty
                    ? MemoryImage(base64Decode(photos[0]))
                    : null,
                child: photos.isEmpty
                    ? const Icon(Icons.person, color: Colors.white30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${fromUser['name'] ?? 'Anonymous'}${fromUser['age'] != null ? ', ${fromUser['age']}' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (minutesRemaining != null)
                      Text(
                        'Expires in ${minutesRemaining}m',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          // Message if any
          if (request['message'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${request['message']}"',
                style: const TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectRequest(request),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Decline', style: TextStyle(color: Colors.white54)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _acceptRequest(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentRequestsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF4444)),
      );
    }

    if (_sentRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send,
        title: 'No sent requests',
        subtitle: 'Requests you send will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFEF4444),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sentRequests.length,
        itemBuilder: (context, index) {
          return _buildSentRequestCard(_sentRequests[index]);
        },
      ),
    );
  }

  Widget _buildSentRequestCard(Map<String, dynamic> request) {
    final toUser = request['to_user'] as Map<String, dynamic>;
    final photos = toUser['photos'] as List? ?? [];
    final status = request['status'] as String;

    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'accepted':
        statusColor = const Color(0xFF22C55E);
        statusText = 'Accepted';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Declined';
        break;
      case 'expired':
        statusColor = Colors.grey;
        statusText = 'Expired';
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF374151),
            backgroundImage: photos.isNotEmpty
                ? MemoryImage(base64Decode(photos[0]))
                : null,
            child: photos.isEmpty
                ? const Icon(Icons.person, color: Colors.white30, size: 20)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              toUser['name'] ?? 'Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF4444)),
      );
    }

    if (_matches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No chats yet',
        subtitle: 'When someone accepts your request or you accept theirs, you can chat here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFEF4444),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          return _buildMatchCard(_matches[index]);
        },
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final user = match['user'] as Map<String, dynamic>;
    final photos = user['photos'] as List? ?? [];

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEF4444), width: 2),
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF374151),
                backgroundImage: photos.isNotEmpty
                    ? MemoryImage(base64Decode(photos[0]))
                    : null,
                child: photos.isEmpty
                    ? const Icon(Icons.person, color: Colors.white30)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['bio'] ?? 'Tap to chat',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
