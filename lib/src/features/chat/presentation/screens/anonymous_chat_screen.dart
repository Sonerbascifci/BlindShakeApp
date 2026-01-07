import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blind_shake/src/app/theme/app_colors.dart';
import 'package:blind_shake/src/app/theme/app_typography.dart';
import 'package:blind_shake/src/shared/widgets/anonymous_avatar.dart';
import 'package:blind_shake/src/shared/widgets/timer_widget.dart';
import 'package:blind_shake/src/features/chat/presentation/providers/chat_providers.dart';
import 'package:blind_shake/src/features/chat/presentation/widgets/decision_modal.dart';
import 'package:blind_shake/src/features/chat/data/models/chat_message.dart';
import 'package:blind_shake/src/features/chat/data/services/chat_service.dart';
import 'package:intl/intl.dart';

class AnonymousChatScreen extends ConsumerStatefulWidget {
  final String? matchId;

  const AnonymousChatScreen({super.key, this.matchId});

  @override
  ConsumerState<AnonymousChatScreen> createState() => _AnonymousChatScreenState();
}

class _AnonymousChatScreenState extends ConsumerState<AnonymousChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timerUpdateTimer;
  bool _decisionModalShown = false;

  @override
  void initState() {
    super.initState();
    // Update timer every second
    _timerUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _timerUpdateTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || widget.matchId == null) return;

    // Clear input immediately for better UX
    _messageController.clear();

    // Send message
    final controller = ref.read(chatControllerNotifierProvider.notifier);
    final success = await controller.sendMessage(
      matchId: widget.matchId!,
      content: content,
    );

    if (success) {
      _scrollToBottom();
    }
  }

  void _showDecisionModal(MatchInfo matchInfo) {
    if (_decisionModalShown || !mounted) return;
    _decisionModalShown = true;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => DecisionModal(
        onReveal: () async {
          Navigator.pop(context);
          await _handleReveal();
        },
        onDecline: () async {
          Navigator.pop(context);
          await _handleDecline();
        },
      ),
    );
  }

  Future<void> _handleReveal() async {
    final controller = ref.read(chatControllerNotifierProvider.notifier);
    final success = await controller.requestReveal(widget.matchId!);

    if (!success && mounted) {
      final error = ref.read(chatErrorNotifierProvider);
      _showErrorSnackBar(error ?? 'Kimlik açığa çıkarılamadı');
    }
  }

  Future<void> _handleDecline() async {
    final controller = ref.read(chatControllerNotifierProvider.notifier);
    final success = await controller.declineReveal(widget.matchId!);

    if (success && mounted) {
      // Navigate back to home
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      final error = ref.read(chatErrorNotifierProvider);
      _showErrorSnackBar(error ?? 'İşlem başarısız');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matchId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(
          child: Text('Geçersiz eşleşme ID\'si'),
        ),
      );
    }

    // Watch match info stream
    final matchInfoAsync = ref.watch(matchInfoStreamProvider(widget.matchId!));

    return matchInfoAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Yükleniyor...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Text('Eşleşme yüklenemedi: $error'),
        ),
      ),
      data: (matchInfo) {
        // Check if decision modal should be shown
        if (matchInfo.isAnonymousPhaseEnded &&
            !matchInfo.isRevealed &&
            !matchInfo.isArchived &&
            !_decisionModalShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showDecisionModal(matchInfo);
          });
        }

        return _buildChatUI(matchInfo);
      },
    );
  }

  Widget _buildChatUI(MatchInfo matchInfo) {
    // Watch messages stream
    final messagesAsync = ref.watch(messagesStreamProvider(widget.matchId!));
    final isSending = ref.watch(sendingMessageNotifierProvider);
    final currentUserId = ref.read(chatControllerNotifierProvider.notifier).getCurrentUserId();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AnonymousAvatar(size: 40, glow: false),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  matchInfo.isRevealed ? 'Kimlik Açığa Çıktı' : 'Bilinmeyen Kişi',
                  style: AppTypography.titleLarge,
                ),
                if (matchInfo.distance != null)
                  Text(
                    '${matchInfo.distance!.toStringAsFixed(1)} km yakında',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 10,
                      color: AppColors.accent,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          if (!matchInfo.isAnonymousPhaseEnded)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TimerWidget(
                remaining: matchInfo.timeRemaining,
                progress: matchInfo.timeRemaining.inSeconds / (15 * 60),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Mesajlar yüklenemedi', style: AppTypography.bodyLarge),
                    const SizedBox(height: 8),
                    Text(error.toString(), style: AppTypography.bodySmall),
                  ],
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'İlk mesajı gönderin!',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    // Handle system messages differently
                    if (message.type == MessageType.system) {
                      return _buildSystemMessage(message.content);
                    }

                    return ChatBubble(
                      message: message.content,
                      isMe: isMe,
                      time: _formatTime(message.timestamp),
                    );
                  },
                );
              },
            ),
          ),
          // Message input
          _buildMessageInput(isSending, matchInfo.isArchived),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String content) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          content,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isSending, bool isArchived) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceLight)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: !isArchived && !isSending,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: isArchived
                        ? 'Sohbet sonlandı'
                        : 'Mesaj yaz...',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isArchived || isSending
                    ? null
                    : AppColors.primaryGradient,
                color: isArchived || isSending
                    ? AppColors.surfaceLight
                    : null,
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: isArchived ? null : _sendMessage,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          border: isMe ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: AppTypography.bodyMedium.copyWith(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
