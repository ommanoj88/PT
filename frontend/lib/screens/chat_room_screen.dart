import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Chat room screen with message bubbles.
class ChatRoomScreen extends StatefulWidget {
  final String matchId;
  final String userName;
  final String? userPhoto;

  const ChatRoomScreen({
    super.key,
    required this.matchId,
    required this.userName,
    this.userPhoto,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await ChatService.getChatHistory(widget.matchId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: ${e.toString()}')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final message = await ChatService.sendMessage(
        matchId: widget.matchId,
        content: content,
      );

      _messageController.clear();

      setState(() {
        _messages.add({
          ...message,
          'is_mine': true,
        });
        _isSending = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: ${e.toString()}')),
        );
      }
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondaryContainer,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.surface,
                backgroundImage: widget.userPhoto != null
                    ? MemoryImage(base64Decode(widget.userPhoto!))
                    : null,
                child: widget.userPhoto == null
                    ? Icon(Icons.person, color: colorScheme.secondary, size: 20)
                    : null,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Text(widget.userName, style: textTheme.titleMedium),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: colorScheme.primary),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppTheme.spacing24),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                                ),
                                child: Text(
                                  '👋',
                                  style: textTheme.displayMedium,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                'Say hello!',
                                style: textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppTheme.spacing16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return AnimatedListItem(
                              index: index,
                              delay: const Duration(milliseconds: 30),
                              child: _buildMessageBubble(_messages[index], colorScheme, textTheme),
                            );
                          },
                        ),
            ),
            // Input field
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.5),
                border: Border(
                  top: BorderSide(color: colorScheme.outline),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing20,
                            vertical: AppTheme.spacing12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    PremiumIconButton(
                      icon: _isSending ? Icons.hourglass_empty : Icons.send_rounded,
                      onPressed: _isSending ? null : () {
                        HapticFeedback.lightImpact();
                        _sendMessage();
                      },
                      size: 48,
                      iconSize: 24,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isMine = message['is_mine'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing12,
            ),
            decoration: BoxDecoration(
              gradient: isMine ? AppTheme.primaryGradient : null,
              color: isMine ? null : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppTheme.radiusLarge),
                topRight: const Radius.circular(AppTheme.radiusLarge),
                bottomLeft: Radius.circular(isMine ? AppTheme.radiusLarge : AppTheme.spacing4),
                bottomRight: Radius.circular(isMine ? AppTheme.spacing4 : AppTheme.radiusLarge),
              ),
              boxShadow: isMine
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              message['content'] ?? '',
              style: textTheme.bodyLarge?.copyWith(
                color: isMine ? Colors.white : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
