import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/notification_service.dart';
import '../../models/alert_model.dart' as alert_models;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<alert_models.AlertHistory> _notifications = [];
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
      final notificationService = NotificationService();
      
      // Tentar carregar do cache primeiro para melhor UX
      if (!forceRefresh && notificationService.cachedNotifications.isNotEmpty) {
        setState(() {
          _notifications = notificationService.cachedNotifications;
          _isLoading = false;
        });
      }

      // Carregar dados atualizados da API
      final notifications = await notificationService.getNotifications('user_id');
      
      if (mounted) {
        setState(() {
          _notifications = notificationService.sortNotifications(notifications);
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
      final notificationService = NotificationService();
      await notificationService.markAsRead(notificationId);
      
      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            // Atualizar a notificação como lida
            final notification = _notifications[index];
            _notifications[index] = alert_models.AlertHistory(
              id: notification.id,
              alertId: notification.alertId,
              userId: notification.userId,
              propertyId: notification.propertyId,
              type: notification.type,
              message: notification.message,
              triggeredAt: notification.triggeredAt,
              wasRead: true,
              metadata: notification.metadata,
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
      final notificationService = NotificationService();
      await notificationService.markAllAsRead('user_id');
      
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((notification) {
            return alert_models.AlertHistory(
              id: notification.id,
              alertId: notification.alertId,
              userId: notification.userId,
              propertyId: notification.propertyId,
              type: notification.type,
              message: notification.message,
              triggeredAt: notification.triggeredAt,
              wasRead: true,
              metadata: notification.metadata,
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
      final notificationService = NotificationService();
      await notificationService.deleteNotification(notificationId);
      
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

  void _handleNotificationTap(alert_models.AlertHistory notification) {
    // Marcar como lida se não estiver lida
    if (!notification.wasRead) {
      _markAsRead(notification.id);
    }

    // Navegar baseado no tipo de notificação
    switch (notification.type) {
      case alert_models.AlertType.statusChange:
      case alert_models.AlertType.priceDrop:
      case alert_models.AlertType.newProperty:
        if (notification.propertyId.isNotEmpty) {
          context.go('/user/property/${notification.propertyId}');
        } else {
          // Mostrar detalhes da notificação se não houver propertyId
          _showNotificationDetails(notification);
        }
        break;
      case alert_models.AlertType.custom:
        // Navegar para a tela de chat geral
        context.go('/user/chat');
        break;
    }
  }

  void _showNotificationDetails(alert_models.AlertHistory notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.message),
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

  IconData _getNotificationIcon(alert_models.AlertType type) {
    switch (type) {
      case alert_models.AlertType.statusChange:
        return Icons.home;
      case alert_models.AlertType.custom:
        return Icons.message;
      case alert_models.AlertType.priceDrop:
        return Icons.trending_down;
      case alert_models.AlertType.newProperty:
        return Icons.add_home;
    }
  }

  Color _getPriorityColor(alert_models.AlertType type) {
    switch (type) {
      case alert_models.AlertType.priceDrop:
        return Colors.red;
      case alert_models.AlertType.newProperty:
        return Colors.green;
      case alert_models.AlertType.statusChange:
        return Colors.orange;
      case alert_models.AlertType.custom:
        return Colors.blue;
    }
  }

  List<alert_models.AlertHistory> _getFilteredNotifications() {
    switch (_selectedFilter) {
      case 'unread':
        return _notifications.where((n) => !n.wasRead).toList();
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
                    '${_notifications.where((n) => !n.wasRead).length}',
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

  Widget _buildNotificationCard(alert_models.AlertHistory notification, bool isTablet) {
    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      elevation: notification.wasRead ? 1 : 3,
      color: notification.wasRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
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
                  color: _getPriorityColor(notification.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getPriorityColor(notification.type),
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
                        if (notification.type == alert_models.AlertType.priceDrop ||
                            notification.type == alert_models.AlertType.priceDrop)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(notification.type),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification.typeDisplayName,
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
