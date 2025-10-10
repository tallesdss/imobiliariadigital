import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import 'property_detail_screen.dart';
import 'user_chat_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, unread, byType

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tentar carregar do cache primeiro para melhor UX
      if (!forceRefresh && NotificationService.cachedNotifications.isNotEmpty) {
        setState(() {
          _notifications = NotificationService.cachedNotifications;
          _isLoading = false;
        });
      }

      // Carregar dados atualizados da API
      final notifications = await NotificationService.getNotifications(
        forceRefresh: forceRefresh,
      );
      
      if (mounted) {
        setState(() {
          _notifications = NotificationService.sortNotifications(notifications);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar notificações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      
      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(
              isRead: true,
              readAt: DateTime.now(),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao marcar como lida: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((notification) {
            return notification.copyWith(
              isRead: true,
              readAt: DateTime.now(),
            );
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas as notificações foram marcadas como lidas'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao marcar todas como lidas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      
      if (mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notificationId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificação removida'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover notificação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Marcar como lida se não estiver lida
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navegar baseado no tipo de notificação
    switch (notification.type) {
      case NotificationType.propertyUpdate:
      case NotificationType.favoriteMatch:
      case NotificationType.priceChange:
      case NotificationType.newProperty:
        if (notification.propertyId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailScreen(
                propertyId: notification.propertyId!,
              ),
            ),
          );
        }
        break;
      case NotificationType.newMessage:
        // Navegar para a tela de chat geral
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserChatScreen(),
          ),
        );
        break;
      case NotificationType.systemAlert:
      case NotificationType.appointmentReminder:
        // Mostrar detalhes da notificação
        _showNotificationDetails(notification);
        break;
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _getNotificationIcon(notification.type),
                  size: 16,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 8),
                Text(
                  notification.typeDisplayName,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notification.timeAgo,
              style: AppTypography.caption.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.propertyUpdate:
        return Icons.home;
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.favoriteMatch:
        return Icons.favorite;
      case NotificationType.systemAlert:
        return Icons.warning;
      case NotificationType.appointmentReminder:
        return Icons.schedule;
      case NotificationType.priceChange:
        return Icons.trending_up;
      case NotificationType.newProperty:
        return Icons.add_home;
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  List<NotificationModel> _getFilteredNotifications() {
    switch (_selectedFilter) {
      case 'unread':
        return NotificationService.getUnreadNotifications(_notifications);
      default:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('Todas'),
                ),
                const PopupMenuItem(
                  value: 'unread',
                  child: Text('Não lidas'),
                ),
              ],
            ),
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Marcar todas',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final filteredNotifications = _getFilteredNotifications();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    if (filteredNotifications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: isTablet ? 80 : 64,
                color: AppColors.textHint,
              ),
              SizedBox(height: isTablet ? 24 : 16),
              Text(
                _selectedFilter == 'unread' 
                    ? 'Nenhuma notificação não lida'
                    : 'Nenhuma notificação',
                style: AppTypography.h6.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 20 : 18,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                _selectedFilter == 'unread'
                    ? 'Você está em dia com suas notificações!'
                    : 'Você receberá notificações sobre imóveis, mensagens e atualizações aqui',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHint,
                  fontSize: isTablet ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (_selectedFilter == 'unread') ...[
                SizedBox(height: isTablet ? 32 : 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'all';
                    });
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Ver Todas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header com contador
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          color: Colors.white,
          child: Row(
            children: [
              Icon(
                Icons.notifications,
                color: AppColors.primary,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                '${filteredNotifications.length} ${filteredNotifications.length == 1 ? 'notificação' : 'notificações'}',
                style: AppTypography.labelLarge.copyWith(
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
              const Spacer(),
              if (_selectedFilter == 'unread')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${NotificationService.getUnreadNotifications(_notifications).length}',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Lista de notificações
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadNotifications(forceRefresh: true),
            child: ListView.builder(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                return _buildNotificationCard(notification, isTablet);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, bool isTablet) {
    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone da notificação
              Container(
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                decoration: BoxDecoration(
                  color: _getPriorityColor(notification.priority).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getPriorityColor(notification.priority),
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              // Conteúdo da notificação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTypography.subtitle1.copyWith(
                              fontWeight: notification.isRead 
                                  ? FontWeight.normal 
                                  : FontWeight.bold,
                              fontSize: isTablet ? 18 : 16,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Text(
                      notification.message,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: isTablet ? 16 : 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Row(
                      children: [
                        Text(
                          notification.timeAgo,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textHint,
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                        const Spacer(),
                        if (notification.priority == NotificationPriority.high ||
                            notification.priority == NotificationPriority.urgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(notification.priority),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification.priorityDisplayName,
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu de ações
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_read':
                      if (!notification.isRead) {
                        _markAsRead(notification.id);
                      }
                      break;
                    case 'delete':
                      _deleteNotification(notification.id);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Text('Marcar como lida'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Remover'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
