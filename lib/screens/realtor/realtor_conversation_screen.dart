import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../services/chat_service.dart';
import '../../models/chat_model.dart';
import '../../widgets/common/chat_bubble.dart';

class RealtorConversationScreen extends StatefulWidget {
  final ChatConversation conversation;

  const RealtorConversationScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<RealtorConversationScreen> createState() => _RealtorConversationScreenState();
}

class _RealtorConversationScreenState extends State<RealtorConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late List<ChatMessage> _messages;
  bool _isLoading = false;
  StreamSubscription<ChatMessage>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.conversation.messages);
    _scrollToBottom();
    
    // Entrar na conversa para receber mensagens em tempo real
    ChatService.joinConversation(widget.conversation.id);
    
    // Escutar novas mensagens
    _messageSubscription = ChatService.messageStream.listen((message) {
      if (message.senderId != ChatService.currentUserId) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    ChatService.leaveConversation();
    _messageController.dispose();
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await ChatService.sendMessage(
        conversationId: widget.conversation.id,
        content: content,
      );

      setState(() {
        _messages.add(message);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar mensagem: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversation.buyerName,
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.conversation.propertyTitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textOnPrimary.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            onPressed: () {
              // Marcar mensagens como lidas
              ChatService.markMessagesAsRead(widget.conversation.id);
            },
            icon: const Icon(Icons.mark_chat_read),
            tooltip: 'Marcar como lida',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.content,
                  senderName: message.senderName,
                  timestamp: message.timestamp,
                  isFromCurrentUser: message.senderId == ChatService.currentUserId,
                  isRead: message.isRead,
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Digite sua mensagem...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : AppSpacing.lg,
                    vertical: isTablet ? 16 : AppSpacing.md,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: isTablet ? 16 : AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: _isLoading ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isLoading ? null : _sendMessage,
                icon: _isLoading 
                    ? SizedBox(
                        width: isTablet ? 24 : 20,
                        height: isTablet ? 24 : 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.send, 
                        color: Colors.white,
                        size: isTablet ? 24 : 20,
                      ),
                padding: EdgeInsets.all(isTablet ? 16 : 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
