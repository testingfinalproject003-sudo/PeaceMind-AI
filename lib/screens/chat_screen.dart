// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/exercise_popup.dart';
import '../providers/chat_provider.dart';
import '../screens/home_screen.dart';
import '../screens/ai_audio_call_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  // ── Progressive history loading state ──
  String? _lastNewestId; // bottom (newest) message id — new message detect
  double? _extentBeforePagination; // older messages insert hone se pehle ka
  // maxScrollExtent — pagination ke baad view stable rakhne ke liye

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      provider.initialize();
      _isInitialized = true;
      log('✅ ChatScreen initialized');
    });
  }

  /// Reverse list mein upar scroll (older messages) → next page load.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels <= 0 || pos.maxScrollExtent - pos.pixels > 300) return;

    final provider = context.read<ChatProvider>();
    if (provider.hasMoreMessages &&
        !provider.isLoadingOlder &&
        !provider.isInitialLoad) {
      _extentBeforePagination = pos.maxScrollExtent;
      provider.loadOlderMessages();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Reverse ListView: offset 0 = bottom (newest message).
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
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

    await provider.sendMessage(text: text, language: 'en');

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

    // Provider khud summary + shared memory + Report entry (local +
    // Firestore) save karta hai — yahan duplicate write ki zaroorat nahi.
    const durationMinutes = 5;

    await provider.endSession(
      durationMinutes: durationMinutes,
      pendingTask: null,
    );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        log(
          '📱 ChatScreen rebuilding with ${chatProvider.messages.length} messages',
        );

        // Auto-show exercise popup when suggested
        final pendingExerciseId = chatProvider.pendingExerciseId;
        if (pendingExerciseId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showExercisePopup(pendingExerciseId);
            chatProvider.clearPendingExercise();
          });
        }

        // ── Progressive history: pagination complete → view stable rakho.
        // Older messages TOP par insert hoti hain (reverse list), isliye
        // scroll offset ko added height ke barah upar shift karte hain.
        if (_extentBeforePagination != null && !chatProvider.isLoadingOlder) {
          final oldMax = _extentBeforePagination!;
          _extentBeforePagination = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scrollController.hasClients) return;
            final delta =
                _scrollController.position.maxScrollExtent - oldMax;
            if (delta > 0 && _scrollController.offset > 0) {
              _scrollController.jumpTo(_scrollController.offset + delta);
            }
          });
        }

        // ── Naya message sirf tab scroll jab user bottom ke paas ho —
        // history parh rahe user ko yank na karo.
        final messages = chatProvider.messages;
        final newestId =
            messages.isNotEmpty ? messages.first['id'] as String? : null;
        if (newestId != null && newestId != _lastNewestId) {
          _lastNewestId = newestId;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scrollController.hasClients) return;
            final pos = _scrollController.position;
            if (pos.pixels < 200) _scrollToBottom();
          });
        }

        // Loading state
        if (chatProvider.isLoading && !_isInitialized) {
          return Scaffold(
            backgroundColor: const Color(0xFFCFE7FF),
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        // Error state — sirf tab jab session hi usable na ho.
        // Send/stream error par conversation ko error screen se MAT
        // chhupao — messages dikhte rehte hain, error SnackBar mein aata hai.
        if (chatProvider.error != null && !chatProvider.isSessionActive) {
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

        // Active session mein error (send/stream fail) → SnackBar,
        // chat UI waisa hi rehta hai (AI fail ho to bhi user message visible).
        if (chatProvider.error != null) {
          final err = chatProvider.error!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            chatProvider.clearError();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(err),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
              ),
            );
          });
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
                onPressed: () async {
                  // Provider pehle capture karo — async gap ke baad builder
                  // context use nahi karna (app-level provider hai, safe).
                  final chatProvider = context.read<ChatProvider>();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AiAudioCallScreen(),
                    ),
                  );
                  // Call ke baad shared memory (chat + call same long-term
                  // memory use karte hain) turant reload karo.
                  chatProvider.refreshUserContext();
                  // Back-button path mein endCall background mein chalta hai
                  // — thodi der baad ek aur refresh taake updated memory pakdi jaye.
                  Future.delayed(const Duration(seconds: 5), () {
                    chatProvider.refreshUserContext();
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: chatProvider.isSessionActive ? _endSession : null,
              ),
            ],
          ),
          body: Column(
            children: [
              // Messages list — reverse: index 0 = bottom (newest),
              // older messages upar gradually load hoti hain.
              Expanded(
                child: chatProvider.isInitialLoad &&
                        chatProvider.messages.isEmpty
                    ? _buildSkeletonList()
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatProvider.messages.length +
                            (chatProvider.isLoadingOlder ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Top par loader jab older messages aa rahi hon
                          if (chatProvider.isLoadingOlder &&
                              index == chatProvider.messages.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            );
                          }
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

  // ============================================================
  // SKELETON (old messages load ho rahe hon)
  // ============================================================

  Widget _buildSkeletonList() {
    return ListView(
      reverse: true,
      padding: const EdgeInsets.all(16),
      children: [
        for (int i = 0; i < 6; i++) _buildSkeletonBubble(i.isEven),
      ],
    );
  }

  Widget _buildSkeletonBubble(bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 46,
        width: MediaQuery.of(context).size.width * (isUser ? 0.45 : 0.65),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fadeIn(duration: 450.ms)
          .then()
          .fadeOut(duration: 450.ms),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';
    final text = message['text'] ?? '';
    final language = message['language'] ?? 'en';

    return Align(
      key: ValueKey(message['id']),
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
              AudioPlayerWidget(text: text, language: language),
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
                side: BorderSide(
                  color: AppColors.inkSoft.withValues(alpha: 0.2),
                ),
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
