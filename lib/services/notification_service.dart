import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../models/alert_model.dart' as alert_models;

/// Serviço para gerenciar alertas e notificações
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  StreamSubscription<QuerySnapshot>? _alertsSubscription;
  StreamSubscription<QuerySnapshot>? _propertiesSubscription;
  
  // Configurações de notificação
  static const String _serverKey = 'YOUR_FCM_SERVER_KEY'; // Substituir pela chave real
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _requestPermissions();
  }

  /// Inicializa notificações locais
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Inicializa Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Configurar handlers para mensagens em background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Configurar handler para mensagens em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Configurar handler para quando o app é aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Solicita permissões de notificação
  Future<void> _requestPermissions() async {
    // Permissões para Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Permissões para iOS
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Permissões para Firebase
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Usuário autorizou notificações');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('Usuário autorizou notificações provisórias');
    } else {
      debugPrint('Usuário negou ou não autorizou notificações');
    }
  }

  /// Handler para notificações em background
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    debugPrint('Mensagem em background: ${message.messageId}');
  }

  /// Handler para mensagens em foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Mensagem em foreground: ${message.messageId}');
    
    // Mostrar notificação local quando o app está em foreground
    await _showLocalNotification(
      title: message.notification?.title ?? 'Nova notificação',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Handler para quando o app é aberto via notificação
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('App aberto via notificação: ${message.messageId}');
    // Navegar para a tela apropriada baseada nos dados da notificação
    _handleNotificationNavigation(message.data);
  }

  /// Handler para quando uma notificação local é tocada
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificação local tocada: ${response.payload}');
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  /// Navega para a tela apropriada baseada nos dados da notificação
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Implementar navegação baseada no tipo de notificação
    final type = data['type'];
    final propertyId = data['propertyId'];
    
    switch (type) {
      case 'price_drop':
      case 'new_property':
      case 'status_change':
        // Navegar para detalhes do imóvel
        if (propertyId != null) {
          // NavigationService.navigateToPropertyDetail(propertyId);
        }
        break;
      default:
        // Navegar para lista de alertas
        // NavigationService.navigateToAlerts();
        break;
    }
  }

  /// Mostra uma notificação local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'property_alerts',
      'Alertas de Imóveis',
      channelDescription: 'Notificações sobre alertas de imóveis',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// Envia notificação push via FCM
  Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
          },
          'data': data ?? {},
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Notificação push enviada com sucesso');
      } else {
        debugPrint('Erro ao enviar notificação push: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao enviar notificação push: $e');
    }
  }

  /// Cria um novo alerta
  Future<String?> createAlert({
    required String userId,
    required alert_models.AlertType type,
    required alert_models.AlertCriteria criteria,
    String? propertyId,
    alert_models.NotificationSettings? notificationSettings,
  }) async {
    try {
      final alertId = _firestore.collection('alerts').doc().id;
      
      final alert = alert_models.PropertyAlert(
        id: alertId,
        userId: userId,
        propertyId: propertyId,
        propertyTitle: criteria.keywords?.isNotEmpty == true 
            ? criteria.keywords!.join(', ')
            : 'Alerta de Imóvel',
        type: type,
        criteria: criteria,
        createdAt: DateTime.now(),
        notificationSettings: notificationSettings ?? alert_models.NotificationSettings(),
      );

      await _firestore.collection('alerts').doc(alertId).set(alert.toMap());
      
      // Iniciar monitoramento se for um alerta ativo
      if (alert.isActive) {
        await _startMonitoringAlert(alert);
      }

      return alertId;
    } catch (e) {
      debugPrint('Erro ao criar alerta: $e');
      return null;
    }
  }

  /// Atualiza um alerta existente
  Future<bool> updateAlert(alert_models.PropertyAlert alert) async {
    try {
      await _firestore.collection('alerts').doc(alert.id).update(alert.toMap());
      
      // Reiniciar monitoramento se o alerta foi ativado/desativado
      if (alert.isActive) {
        await _startMonitoringAlert(alert);
      } else {
        await _stopMonitoringAlert(alert.id);
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar alerta: $e');
      return false;
    }
  }

  /// Remove um alerta
  Future<bool> deleteAlert(String alertId) async {
    try {
      await _stopMonitoringAlert(alertId);
      await _firestore.collection('alerts').doc(alertId).delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao remover alerta: $e');
      return false;
    }
  }

  /// Obtém alertas de um usuário
  Future<List<alert_models.PropertyAlert>> getUserAlerts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('alerts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => alert_models.PropertyAlert.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erro ao obter alertas do usuário: $e');
      return [];
    }
  }

  /// Obtém histórico de alertas de um usuário
  Future<List<alert_models.AlertHistory>> getAlertHistory(String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('alert_history')
          .where('userId', isEqualTo: userId)
          .orderBy('triggeredAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => alert_models.AlertHistory.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erro ao obter histórico de alertas: $e');
      return [];
    }
  }

  /// Inicia o monitoramento de um alerta
  Future<void> _startMonitoringAlert(alert_models.PropertyAlert alert) async {
    // Parar monitoramento anterior se existir
    await _stopMonitoringAlert(alert.id);

    // Configurar listener para mudanças nos imóveis
    _propertiesSubscription = _firestore
        .collection('properties')
        .snapshots()
        .listen((snapshot) {
      _checkAlertTriggers(alert, snapshot.docs);
    });
  }

  /// Para o monitoramento de um alerta
  Future<void> _stopMonitoringAlert(String alertId) async {
    await _propertiesSubscription?.cancel();
    _propertiesSubscription = null;
  }

  /// Verifica se um alerta deve ser disparado
  Future<void> _checkAlertTriggers(
    alert_models.PropertyAlert alert,
    List<QueryDocumentSnapshot> properties,
  ) async {
    if (!alert.isActive || !alert.notificationSettings.canSendNotification()) {
      return;
    }

    for (final doc in properties) {
      final propertyData = doc.data() as Map<String, dynamic>;
      final propertyId = doc.id;

      // Verificar se o imóvel atende aos critérios
      if (alert.criteria.matchesProperty(propertyData)) {
        await _triggerAlert(alert, propertyId, propertyData);
      }
    }
  }

  /// Dispara um alerta
  Future<void> _triggerAlert(
    alert_models.PropertyAlert alert,
    String propertyId,
    Map<String, dynamic> propertyData,
  ) async {
    try {
      // Verificar se já foi disparado recentemente (evitar spam)
      final now = DateTime.now();
      if (alert.lastTriggered != null &&
          now.difference(alert.lastTriggered!).inHours < 1) {
        return;
      }

      // Criar mensagem baseada no tipo de alerta
      final message = _createAlertMessage(alert.type, propertyData);
      
      // Criar histórico do alerta
      final historyId = _firestore.collection('alert_history').doc().id;
      final history = alert_models.AlertHistory(
        id: historyId,
        alertId: alert.id,
        userId: alert.userId,
        propertyId: propertyId,
        type: alert.type,
        message: message,
        triggeredAt: now,
        metadata: {
          'propertyData': propertyData,
          'alertCriteria': alert.criteria.toMap(),
        },
      );

      await _firestore.collection('alert_history').doc(historyId).set(history.toMap());

      // Enviar notificação
      await _sendAlertNotification(alert, propertyId, message, propertyData);

      // Atualizar contador de disparos do alerta
      await _firestore.collection('alerts').doc(alert.id).update({
        'lastTriggered': Timestamp.fromDate(now),
        'triggerCount': FieldValue.increment(1),
      });

    } catch (e) {
      debugPrint('Erro ao disparar alerta: $e');
    }
  }

  /// Cria mensagem personalizada baseada no tipo de alerta
  String _createAlertMessage(alert_models.AlertType type, Map<String, dynamic> propertyData) {
    final title = propertyData['title'] ?? 'Imóvel';
    final price = propertyData['price']?.toString() ?? 'N/A';
    final city = propertyData['city'] ?? '';
    final neighborhood = propertyData['neighborhood'] ?? '';

    switch (type) {
      case alert_models.AlertType.priceDrop:
      case alert_models.AlertType.priceReduction:
        return '💰 Preço baixou! $title em $neighborhood, $city - R\$ $price';
      case alert_models.AlertType.statusChange:
      case alert_models.AlertType.sold:
        return '📋 Status alterado! $title em $neighborhood, $city - R\$ $price';
      case alert_models.AlertType.newProperty:
      case alert_models.AlertType.newSimilar:
        return '🆕 Novo imóvel! $title em $neighborhood, $city - R\$ $price';
      case alert_models.AlertType.custom:
        return '🔔 Alerta personalizado! $title em $neighborhood, $city - R\$ $price';
    }
  }

  /// Envia notificação do alerta
  Future<void> _sendAlertNotification(
    alert_models.PropertyAlert alert,
    String propertyId,
    String message,
    Map<String, dynamic> propertyData,
  ) async {
    final settings = alert.notificationSettings;

    // Notificação local
    if (settings.pushEnabled) {
      await _showLocalNotification(
        title: 'Alerta de Imóvel',
        body: message,
        payload: jsonEncode({
          'type': alert.type.name,
          'propertyId': propertyId,
          'alertId': alert.id,
        }),
      );
    }

    // Notificação push (se configurada)
    if (settings.pushEnabled) {
      // Obter token FCM do usuário
      final userToken = await _getUserFCMToken(alert.userId);
      if (userToken != null) {
        await sendPushNotification(
          token: userToken,
          title: 'Alerta de Imóvel',
          body: message,
          data: {
            'type': alert.type.name,
            'propertyId': propertyId,
            'alertId': alert.id,
          },
        );
      }
    }

    // Email (se configurado)
    if (settings.emailEnabled) {
      await _sendEmailNotification(alert.userId, message, propertyData);
    }

    // SMS (se configurado)
    if (settings.smsEnabled) {
      await _sendSMSNotification(alert.userId, message);
    }
  }

  /// Obtém token FCM do usuário
  Future<String?> _getUserFCMToken(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['fcmToken'];
    } catch (e) {
      debugPrint('Erro ao obter token FCM: $e');
      return null;
    }
  }

  /// Salva token FCM do usuário
  Future<void> saveUserFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'lastTokenUpdate': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Erro ao salvar token FCM: $e');
    }
  }

  /// Envia notificação por email
  Future<void> _sendEmailNotification(
    String userId,
    String message,
    Map<String, dynamic> propertyData,
  ) async {
    // Implementar integração com serviço de email
    // Por exemplo, SendGrid, AWS SES, etc.
    debugPrint('Enviando email para usuário $userId: $message');
  }

  /// Envia notificação por SMS
  Future<void> _sendSMSNotification(String userId, String message) async {
    // Implementar integração com serviço de SMS
    // Por exemplo, Twilio, AWS SNS, etc.
    debugPrint('Enviando SMS para usuário $userId: $message');
  }

  /// Marca alerta como lido
  Future<bool> markAlertAsRead(String historyId) async {
    try {
      await _firestore.collection('alert_history').doc(historyId).update({
        'wasRead': true,
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao marcar alerta como lido: $e');
      return false;
    }
  }

  /// Obtém estatísticas de alertas
  Future<Map<String, dynamic>> getAlertStats(String userId) async {
    try {
      final alerts = await getUserAlerts(userId);
      final history = await getAlertHistory(userId, limit: 100);

      final activeAlerts = alerts.where((a) => a.isActive).length;
      final totalTriggers = history.length;
      final unreadAlerts = history.where((h) => !h.wasRead).length;

      return {
        'totalAlerts': alerts.length,
        'activeAlerts': activeAlerts,
        'totalTriggers': totalTriggers,
        'unreadAlerts': unreadAlerts,
        'alertsByType': _groupAlertsByType(alerts),
      };
    } catch (e) {
      debugPrint('Erro ao obter estatísticas de alertas: $e');
      return {};
    }
  }

  /// Agrupa alertas por tipo
  Map<String, int> _groupAlertsByType(List<alert_models.PropertyAlert> alerts) {
    final Map<String, int> grouped = {};
    for (final alert in alerts) {
      final type = alert.type.name;
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }

  /// Limpa dados antigos do histórico
  Future<void> cleanupOldHistory({int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final oldHistory = await _firestore
          .collection('alert_history')
          .where('triggeredAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (final doc in oldHistory.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      debugPrint('Histórico antigo limpo: ${oldHistory.docs.length} registros removidos');
    } catch (e) {
      debugPrint('Erro ao limpar histórico antigo: $e');
    }
  }

  /// Obtém notificações de um usuário
  Future<List<alert_models.AlertHistory>> getNotifications(String userId) async {
    return await getAlertHistory(userId);
  }

  /// Obtém notificações não lidas
  Future<List<alert_models.AlertHistory>> getUnreadNotifications(String userId) async {
    final notifications = await getAlertHistory(userId);
    return notifications.where((n) => !n.wasRead).toList();
  }

  /// Obtém contagem de notificações não lidas
  Future<int> getUnreadCount(String userId) async {
    final unreadNotifications = await getUnreadNotifications(userId);
    return unreadNotifications.length;
  }

  /// Ordena notificações por data
  List<alert_models.AlertHistory> sortNotifications(List<alert_models.AlertHistory> notifications) {
    notifications.sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
    return notifications;
  }

  /// Marca notificação como lida
  Future<bool> markAsRead(String historyId) async {
    return await markAlertAsRead(historyId);
  }

  /// Marca todas as notificações como lidas
  Future<bool> markAllAsRead(String userId) async {
    try {
      final unreadNotifications = await getUnreadNotifications(userId);
      final batch = _firestore.batch();
      
      for (final notification in unreadNotifications) {
        batch.update(
          _firestore.collection('alert_history').doc(notification.id),
          {'wasRead': true}
        );
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Erro ao marcar todas as notificações como lidas: $e');
      return false;
    }
  }

  /// Remove uma notificação
  Future<bool> deleteNotification(String historyId) async {
    try {
      await _firestore.collection('alert_history').doc(historyId).delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao remover notificação: $e');
      return false;
    }
  }

  /// Notificações em cache (para uso em tempo real)
  List<alert_models.AlertHistory> cachedNotifications = [];

  /// Dispose do serviço
  void dispose() {
    _alertsSubscription?.cancel();
    _propertiesSubscription?.cancel();
  }
}