import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class RealtorChatScreen extends StatefulWidget {
  const RealtorChatScreen({super.key});

  @override
  State<RealtorChatScreen> createState() => _RealtorChatScreenState();
}

class _RealtorChatScreenState extends State<RealtorChatScreen> {
  List<ChatConversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        // Mock: Conversas de usuários interessados nos imóveis do corretor
        _conversations = [
          ChatConversation(
            id: 'conv1',
            propertyId: 'prop1',
            propertyTitle: 'Casa de Praia em Guarujá',
            otherUserId: 'user1',
            otherUserName: 'João Silva',
            otherUserPhoto:
                'https://ui-avatars.com/api/?name=Joao+Silva&size=200',
            lastMessage: 'Olá, gostaria de agendar uma visita!',
            lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
            unreadCount: 3,
          ),
          ChatConversation(
            id: 'conv2',
            propertyId: 'prop2',
            propertyTitle: 'Apartamento Moderno Centro',
            otherUserId: 'user2',
            otherUserName: 'Maria Santos',
            otherUserPhoto:
                'https://ui-avatars.com/api/?name=Maria+Santos&size=200',
            lastMessage: 'Obrigada pelas informações!',
            lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
            unreadCount: 0,
          ),
          ChatConversation(
            id: 'conv3',
            propertyId: 'prop1',
            propertyTitle: 'Casa de Praia em Guarujá',
            otherUserId: 'user3',
            otherUserName: 'Pedro Alves',
            otherUserPhoto:
                'https://ui-avatars.com/api/?name=Pedro+Alves&size=200',
            lastMessage: 'Qual o valor do condomínio?',
            lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
            unreadCount: 1,
          ),
          ChatConversation(
            id: 'conv4',
            propertyId: 'prop3',
            propertyTitle: 'Sala Comercial Av. Paulista',
            otherUserId: 'user4',
            otherUserName: 'Ana Costa',
            otherUserPhoto:
                'https://ui-avatars.com/api/?name=Ana+Costa&size=200',
            lastMessage: 'O imóvel ainda está disponível?',
            lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
            unreadCount: 0,
          ),
        ];
        _isLoading = false;
      });
    });
  }

  void _openConversation(ChatConversation conversation) {
    Navigator.pushNamed(
      context,
      '/chat-detail',
      arguments: {
        'conversationId': conversation.id,
        'propertyTitle': conversation.propertyTitle,
        'otherUserName': conversation.otherUserName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Conversas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhuma conversa',
              style: AppTypography.h6.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Quando usuários entrarem em contato sobre\nseus imóveis, as conversas aparecerão aqui',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final unreadCount =
        _conversations.where((c) => c.unreadCount > 0).length;

    return Column(
      children: [
        if (unreadCount > 0) _buildUnreadHeader(unreadCount),
        Expanded(child: _buildConversationsList()),
      ],
    );
  }

  Widget _buildUnreadHeader(int count) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mark_chat_unread,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$count ${count == 1 ? 'conversa não lida' : 'conversas não lidas'}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _buildConversationItem(conversation);
      },
    );
  }

  Widget _buildConversationItem(ChatConversation conversation) {
    final isUnread = conversation.unreadCount > 0;
    final timeAgo = _formatTimeAgo(conversation.lastMessageTime);

    return InkWell(
      onTap: () => _openConversation(conversation),
      child: Container(
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          border: const Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar do usuário
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: conversation.otherUserPhoto != null
                      ? NetworkImage(conversation.otherUserPhoto!)
                      : null,
                  backgroundColor: AppColors.primary,
                  child: conversation.otherUserPhoto == null
                      ? Text(
                          conversation.otherUserName[0].toUpperCase(),
                          style: AppTypography.h6.copyWith(
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            // Conteúdo da conversa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: AppTypography.subtitle1.copyWith(
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: AppTypography.bodySmall.copyWith(
                          color: isUnread
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Título do imóvel
                  Row(
                    children: [
                      const Icon(
                        Icons.home_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          conversation.propertyTitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Última mensagem
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isUnread
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight:
                                isUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: AppSpacing.sm),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

class ChatConversation {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}
