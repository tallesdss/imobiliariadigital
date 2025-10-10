import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/fixed_sidebar.dart';
import '../../widgets/common/custom_drawer.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> with TickerProviderStateMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'todos'; // 'todos', 'corretores', 'usuarios'
  late TabController _tabController;
  bool _sidebarVisible = true;
  List<ChatConversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadConversations() async {
    try {
      final conversations = await ChatService.getConversations();
      setState(() {
        _conversations = conversations;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar conversas: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<ChatConversation> get _filteredConversations {
    var conversations = _conversations;
    
    // Filtrar por tipo de conversa
    if (_selectedFilter == 'corretores') {
      conversations = conversations.where((c) => 
          c.realtorName.isNotEmpty && c.buyerName.isEmpty).toList();
    } else if (_selectedFilter == 'usuarios') {
      conversations = conversations.where((c) => 
          c.buyerName.isNotEmpty).toList();
    } else if (_selectedFilter == 'nao_lidas') {
      conversations = conversations.where((c) => 
          c.messages.any((m) => !m.isRead && m.senderId != 'admin')).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      conversations = conversations.where((c) =>
          c.propertyTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.buyerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.realtorName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    // Ordenar por última mensagem (mais recente primeiro)
    conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    
    return conversations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          // Botão para alternar sidebar
          IconButton(
            onPressed: () {
              setState(() {
                _sidebarVisible = !_sidebarVisible;
              });
            },
            icon: Icon(_sidebarVisible ? Icons.menu_open : Icons.menu),
            tooltip: _sidebarVisible ? 'Ocultar menu' : 'Mostrar menu',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textOnPrimary,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedFilter = 'todos';
                  break;
                case 1:
                  _selectedFilter = 'corretores';
                  break;
                case 2:
                  _selectedFilter = 'usuarios';
                  break;
              }
            });
          },
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Corretores'),
            Tab(text: 'Usuários'),
          ],
        ),
      ),
      body: Row(
        children: [
          // Sidebar fixa de navegação
          FixedSidebar(
            type: SidebarType.navigation,
            userType: DrawerUserType.admin,
            userName: 'Administrador',
            userEmail: 'admin@imobiliaria.com',
            currentRoute: '/admin/chat',
            isVisible: _sidebarVisible,
            onToggleVisibility: () {
              setState(() {
                _sidebarVisible = !_sidebarVisible;
              });
            },
          ),
          
          // Conteúdo principal
          Expanded(
            child: Column(
              children: [
                _buildSearchSection(),
                _buildFilterChips(),
                Expanded(
                  child: _buildConversationsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: _selectedFilter == 'corretores' 
              ? 'Buscar conversas com corretores...'
              : _selectedFilter == 'usuarios'
                  ? 'Buscar conversas com usuários...'
                  : 'Buscar conversas...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Filtros: ',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todas', 'todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Com Corretores', 'corretores'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Com Usuários', 'usuarios'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Não Lidas', 'nao_lidas'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTypography.bodySmall.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildConversationsList() {
    final conversations = _filteredConversations;
    
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma conversa encontrada',
              style: AppTypography.h6.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'As conversas aparecerão aqui quando usuários entrarem em contato',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationCard(conversation);
      },
    );
  }

  Widget _buildConversationCard(ChatConversation conversation) {
    final lastMessage = conversation.messages.isNotEmpty 
        ? conversation.messages.last 
        : null;
    final hasUnreadMessages = conversation.messages.any((m) => !m.isRead && m.senderId != 'admin');
    final isRealtorConversation = conversation.realtorName.isNotEmpty && conversation.buyerName.isEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isRealtorConversation 
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openConversation(conversation),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isRealtorConversation 
                      ? AppColors.primary 
                      : AppColors.secondary,
                  child: Text(
                    isRealtorConversation 
                        ? conversation.realtorName.substring(0, 1).toUpperCase()
                        : conversation.buyerName.substring(0, 1).toUpperCase(),
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Conteúdo da conversa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome e badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isRealtorConversation 
                                  ? conversation.realtorName
                                  : conversation.buyerName,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isRealtorConversation)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Corretor',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (conversation.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                conversation.unreadCount.toString(),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Título do imóvel
                      Text(
                        conversation.propertyTitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Informações adicionais
                      if (!isRealtorConversation)
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Corretor: ${conversation.realtorName}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      if (isRealtorConversation)
                        Row(
                          children: [
                            const Icon(
                              Icons.business_outlined,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Conversa direta com corretor',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      // Última mensagem
                      if (lastMessage != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lastMessage.content,
                                style: AppTypography.bodySmall.copyWith(
                                  color: hasUnreadMessages 
                                      ? AppColors.textPrimary 
                                      : AppColors.textSecondary,
                                  fontWeight: hasUnreadMessages 
                                      ? FontWeight.w500 
                                      : FontWeight.normal,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(lastMessage.timestamp),
                              style: AppTypography.labelSmall.copyWith(
                                color: hasUnreadMessages 
                                    ? AppColors.primary 
                                    : AppColors.textHint,
                                fontWeight: hasUnreadMessages 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'Nenhuma mensagem ainda',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textHint,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Indicador de status
                Column(
                  children: [
                    Icon(
                      Icons.chevron_right,
                      color: hasUnreadMessages 
                          ? AppColors.primary 
                          : AppColors.textHint,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    if (hasUnreadMessages)
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Agora';
    }
  }

  void _openConversation(ChatConversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conversa - ${conversation.propertyTitle}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usuário: ${conversation.buyerName}'),
            Text('Corretor: ${conversation.realtorName}'),
            const SizedBox(height: 16),
            Text(
              'Mensagens:',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: conversation.messages.isEmpty
                  ? const Center(
                      child: Text('Nenhuma mensagem ainda'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: conversation.messages.length,
                      itemBuilder: (context, index) {
                        final message = conversation.messages[index];
                        return _buildMessageBubble(message);
                      },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendMessage(conversation);
            },
            child: const Text('Responder'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isFromUser = message.senderId != 'admin';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isFromUser 
            ? MainAxisAlignment.start 
            : MainAxisAlignment.end,
        children: [
          if (!isFromUser) const Spacer(),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isFromUser 
                    ? AppColors.surfaceVariant 
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.senderName,
                    style: AppTypography.labelSmall.copyWith(
                      color: isFromUser 
                          ? AppColors.textSecondary 
                          : AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.content,
                    style: AppTypography.bodySmall.copyWith(
                      color: isFromUser 
                          ? AppColors.textPrimary 
                          : AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTypography.overline.copyWith(
                      color: isFromUser 
                          ? AppColors.textHint 
                          : AppColors.textOnPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromUser) const Spacer(),
        ],
      ),
    );
  }

  void _sendMessage(ChatConversation conversation) {
    showDialog(
      context: context,
      builder: (context) {
        final messageController = TextEditingController();
        bool isLoading = false;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Enviar Mensagem'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Para: ${conversation.buyerName}'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !isLoading,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (messageController.text.trim().isNotEmpty) {
                      setDialogState(() {
                        isLoading = true;
                      });
                      
                      try {
                        await ChatService.sendMessage(
                          conversationId: conversation.id,
                          content: messageController.text.trim(),
                        );
                        
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          _loadConversations(); // Recarregar conversas
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mensagem enviada com sucesso!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isLoading = false;
                        });
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao enviar mensagem: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
