import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  static const String _cacheKey = 'notifications_cache';
  static const String _unreadCountKey = 'unread_notifications_count';
  
  // Cache local para notificações
  static List<NotificationModel> _cachedNotifications = [];
  static int _unreadCount = 0;

  // Getters
  static List<NotificationModel> get cachedNotifications => _cachedNotifications;
  static int get unreadCount => _unreadCount;

  /// Carrega notificações do cache local
  static Future<void> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final unreadCountData = prefs.getInt(_unreadCountKey);

      if (cachedData != null) {
        final List<dynamic> jsonList = 
            (await Future.value(cachedData)).split('\n').map((line) {
          if (line.trim().isEmpty) return null;
          return line;
        }).where((item) => item != null).toList();
        
        _cachedNotifications = jsonList
            .map((json) => NotificationModel.fromJson(
                Map<String, dynamic>.from(
                  json.split('|').asMap().map((i, v) => 
                    MapEntry(v.split(':')[0], v.split(':')[1])
                  )
                )
              )
            )
            .toList();
      }

      _unreadCount = unreadCountData ?? 0;
    } catch (e) {
      // Erro ao carregar notificações do cache - usar valores padrão
      _cachedNotifications = [];
      _unreadCount = 0;
    }
  }

  /// Salva notificações no cache local
  static Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Salva notificações (formato simplificado para SharedPreferences)
      final cacheData = _cachedNotifications
          .map((notification) => notification.toJson().entries
              .map((e) => '${e.key}:${e.value}')
              .join('|'))
          .join('\n');
      
      await prefs.setString(_cacheKey, cacheData);
      await prefs.setInt(_unreadCountKey, _unreadCount);
    } catch (e) {
      // Erro ao salvar notificações no cache - continuar sem cache
    }
  }

  /// Busca todas as notificações do usuário
  static Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // Se não for refresh forçado e temos cache, retorna do cache
      if (!forceRefresh && _cachedNotifications.isNotEmpty) {
        return _cachedNotifications;
      }

      final response = await ApiService.dio.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['notifications'] ?? [];
        final notifications = jsonList
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Atualiza cache
        _cachedNotifications = notifications;
        _unreadCount = response.data['unreadCount'] ?? 0;
        await _saveToCache();

        return notifications;
      }
      throw Exception('Erro ao carregar notificações');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (e.response?.statusCode == 404) {
        // Retorna lista vazia se não há notificações
        _cachedNotifications = [];
        _unreadCount = 0;
        await _saveToCache();
        return [];
      } else {
        throw Exception('Erro ao carregar notificações');
      }
    } catch (e) {
      // Em caso de erro, retorna cache se disponível
      if (_cachedNotifications.isNotEmpty) {
        return _cachedNotifications;
      }
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Marca uma notificação como lida
  static Future<void> markAsRead(String notificationId) async {
    try {
      final response = await ApiService.dio.put(
        '/notifications/$notificationId/read',
      );

      if (response.statusCode == 200) {
        // Atualiza cache local
        final index = _cachedNotifications.indexWhere(
          (n) => n.id == notificationId,
        );
        
        if (index != -1) {
          _cachedNotifications[index] = _cachedNotifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          
          // Atualiza contador de não lidas
          if (!_cachedNotifications[index].isRead) {
            _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          }
          
          await _saveToCache();
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Notificação não encontrada');
      } else {
        throw Exception('Erro ao marcar notificação como lida');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Marca todas as notificações como lidas
  static Future<void> markAllAsRead() async {
    try {
      final response = await ApiService.dio.put('/notifications/read-all');

      if (response.statusCode == 200) {
        // Atualiza cache local
        _cachedNotifications = _cachedNotifications.map((notification) {
          return notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }).toList();
        
        _unreadCount = 0;
        await _saveToCache();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao marcar todas as notificações como lidas');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Remove uma notificação
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await ApiService.dio.delete(
        '/notifications/$notificationId',
      );

      if (response.statusCode == 200) {
        // Remove do cache local
        final wasUnread = _cachedNotifications
            .firstWhere((n) => n.id == notificationId, orElse: () => 
                NotificationModel(
                  id: '',
                  title: '',
                  message: '',
                  type: NotificationType.systemAlert,
                  createdAt: DateTime.now(),
                )
              ).isRead == false;
        
        _cachedNotifications.removeWhere((n) => n.id == notificationId);
        
        if (wasUnread) {
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
        }
        
        await _saveToCache();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Notificação não encontrada');
      } else {
        throw Exception('Erro ao remover notificação');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Obtém contagem de notificações não lidas
  static Future<int> getUnreadCount() async {
    try {
      final response = await ApiService.dio.get('/notifications/unread-count');

      if (response.statusCode == 200) {
        _unreadCount = response.data['count'] ?? 0;
        await _saveToCache();
        return _unreadCount;
      }
      return _unreadCount;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        return _unreadCount;
      }
    } catch (e) {
      return _unreadCount;
    }
  }

  /// Filtra notificações por tipo
  static List<NotificationModel> filterByType(
    List<NotificationModel> notifications,
    NotificationType type,
  ) {
    return notifications.where((n) => n.type == type).toList();
  }

  /// Filtra notificações não lidas
  static List<NotificationModel> getUnreadNotifications(
    List<NotificationModel> notifications,
  ) {
    return notifications.where((n) => !n.isRead).toList();
  }

  /// Ordena notificações por prioridade e data
  static List<NotificationModel> sortNotifications(
    List<NotificationModel> notifications,
  ) {
    final sorted = List<NotificationModel>.from(notifications);
    sorted.sort((a, b) {
      // Primeiro por não lidas
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1;
      }
      
      // Depois por prioridade
      final priorityOrder = {
        NotificationPriority.urgent: 0,
        NotificationPriority.high: 1,
        NotificationPriority.medium: 2,
        NotificationPriority.low: 3,
      };
      
      final aPriority = priorityOrder[a.priority] ?? 2;
      final bPriority = priorityOrder[b.priority] ?? 2;
      
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      
      // Por último por data (mais recente primeiro)
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return sorted;
  }

  /// Limpa cache local
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_unreadCountKey);
      _cachedNotifications = [];
      _unreadCount = 0;
    } catch (e) {
      // Erro ao limpar cache de notificações - continuar
    }
  }

  /// Inicializa o serviço
  static Future<void> initialize() async {
    await loadFromCache();
  }
}
