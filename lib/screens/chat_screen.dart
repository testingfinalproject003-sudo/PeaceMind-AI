// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/exercise_popup.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      provider.initialize();
      _isInitialized = true;
      log('✅ ChatScreen initialized');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<ChatProvider>();
    _controller.clear();

    await provider.sendMessage(
      text: text,
      language: 'en',
    );

    _scrollToBottom();
  }

  void _showExercisePopup(String exerciseId) {
    ExercisePopup.show(
      context: context,
      exerciseId: exerciseId,
      onCancel: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise declined. I\'m here if you need me.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Future<void> _endSession() async {
    final provider = context.read<ChatProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text(
          'Your session will be saved and you can continue later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Talking'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final durationMinutes = 5;
    await provider.endSession(
      durationMinutes: durationMinutes,
      pendingTask: null,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session ended. Your progress has been saved.'),
          duration: Duration(seconds: 3),
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        log('📱 ChatScreen rebuilding with ${chatProvider.messages.length} messages');

        // Auto-show exercise popup when suggested
        final pendingExerciseId = chatProvider.pendingExerciseId;
        if (pendingExerciseId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showExercisePopup(pendingExerciseId);
            chatProvider.clearPendingExercise();
          });
        }

        final messageCount = chatProvider.messages.length;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (messageCount > 0) _scrollToBottom();
        });

        // Loading state
        if (chatProvider.isLoading && !_isInitialized) {
          return Scaffold(
            backgroundColor: AppColors.skyMid,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        // Error state
        if (chatProvider.error != null) {
          return Scaffold(
            backgroundColor: AppColors.skyMid,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    chatProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      chatProvider.clearError();
                      chatProvider.initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Main Chat UI
        return Scaffold(
          backgroundColor: AppColors.skyMid,
          appBar: AppBar(
            title: const Text('NOVA'),
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.fitness_center),
                onSelected: _showExercisePopup,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'box_breathing',
                    child: Text('Box Breathing'),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: chatProvider.isSessionActive ? _endSession : null,
              ),
            ],
          ),
          body: Column(
            children: [
              // Messages list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              // Quick replies
              _buildQuickReplies(),
              // Input area
              _buildInputArea(chatProvider),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // UI BUILDERS
  // ============================================================

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';
    final text = message['text'] ?? '';
    final language = message['language'] ?? 'en';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.white : AppColors.accent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 16 : 4),
            topRight: Radius.circular(isUser ? 4 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser ? AppColors.ink : Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            if (!isUser) ...[
              const SizedBox(height: 4),
              AudioPlayerWidget(
                text: text,
                language: language,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    final chips = [
      "I'm feeling anxious",
      "I can't sleep",
      "I feel overwhelmed",
      "I'm better now",
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((label) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(label),
                backgroundColor: AppColors.glass,
                side: BorderSide(color: AppColors.inkSoft.withValues(alpha: 0.2)),
                onPressed: () {
                  _controller.text = label;
                  FocusScope.of(context).requestFocus(FocusNode());
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatProvider provider) {
    final isSending = provider.isSending;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassStrong,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Talk to NOVA...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              enabled: !isSending && provider.isSessionActive,
            ),
          ),
          IconButton(
            icon: isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  )
                : const Icon(Icons.send),
            color: AppColors.accent,
            onPressed: isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}