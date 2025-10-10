import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/chat_model.dart';
import 'api_service.dart';

class ChatService {
  static WebSocketChannel? _channel;
  static StreamController<ChatMessage>? _messageStreamController;
  static StreamController<ChatConversation>? _conversationStreamController;
  static String? _currentUserId;
  static String? _currentConversationId;

  // Streams para receber mensagens em tempo real
  static Stream<ChatMessage> get messageStream => 
      _messageStreamController?.stream ?? const Stream.empty();
  
  static Stream<ChatConversation> get conversationStream => 
      _conversationStreamController?.stream ?? const Stream.empty();

  /// Inicializa o serviço de chat
  static Future<void> initialize(String userId) async {
    _currentUserId = userId;
    _messageStreamController = StreamController<ChatMessage>.broadcast();
    _conversationStreamController = StreamController<ChatConversation>.broadcast();
    
    // Conectar ao WebSocket para mensagens em tempo real
    await _connectWebSocket();
  }

  /// Conecta ao WebSocket para receber mensagens em tempo real
  static Future<void> _connectWebSocket() async {
    try {
      final wsUrl = 'ws://localhost:3000/ws/chat';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Enviar identificação do usuário
      _channel!.sink.add(jsonEncode({
        'type': 'auth',
        'userId': _currentUserId,
      }));

      // Escutar mensagens do WebSocket
      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            _handleWebSocketMessage(message);
          } catch (e) {
            // Log error silently
          }
        },
        onError: (error) {
          // Tentar reconectar após 5 segundos
          Future.delayed(const Duration(seconds: 5), () {
            if (_currentUserId != null) {
              _connectWebSocket();
            }
          });
        },
        onDone: () {
          // Tentar reconectar após 3 segundos
          Future.delayed(const Duration(seconds: 3), () {
            if (_currentUserId != null) {
              _connectWebSocket();
            }
          });
        },
      );
    } catch (e) {
      // Log error silently
    }
  }

  /// Processa mensagens recebidas via WebSocket
  static void _handleWebSocketMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'new_message':
        final chatMessage = ChatMessage.fromJson(message['data']);
        _messageStreamController?.add(chatMessage);
        break;
      case 'conversation_updated':
        final conversation = ChatConversation.fromJson(message['data']);
        _conversationStreamController?.add(conversation);
        break;
      case 'message_read':
        // Atualizar status de leitura de mensagem
        break;
    }
  }

  /// Lista todas as conversas do usuário
  static Future<List<ChatConversation>> getConversations() async {
    try {
      final response = await ApiService.dio.get('/conversations');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChatConversation.fromJson(json)).toList();
      }
      throw Exception('Erro ao carregar conversas');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao carregar conversas: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Obtém uma conversa específica com suas mensagens
  static Future<ChatConversation> getConversation(String conversationId) async {
    try {
      final response = await ApiService.dio.get('/conversations/$conversationId');
      
      if (response.statusCode == 200) {
        return ChatConversation.fromJson(response.data);
      }
      throw Exception('Erro ao carregar conversa');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Conversa não encontrada');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao carregar conversa: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Cria uma nova conversa
  static Future<ChatConversation> createConversation({
    required String propertyId,
    required String realtorId,
    String? initialMessage,
  }) async {
    try {
      final response = await ApiService.dio.post('/conversations', data: {
        'propertyId': propertyId,
        'realtorId': realtorId,
        'initialMessage': initialMessage,
      });
      
      if (response.statusCode == 201) {
        return ChatConversation.fromJson(response.data);
      }
      throw Exception('Erro ao criar conversa');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Conversa já existe para este imóvel');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao criar conversa: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Envia uma mensagem
  static Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final response = await ApiService.dio.post('/messages', data: {
        'conversationId': conversationId,
        'content': content,
        'type': type.name,
      });
      
      if (response.statusCode == 201) {
        final message = ChatMessage.fromJson(response.data);
        
        // Enviar via WebSocket para outros participantes
        _channel?.sink.add(jsonEncode({
          'type': 'send_message',
          'conversationId': conversationId,
          'message': message.toJson(),
        }));
        
        return message;
      }
      throw Exception('Erro ao enviar mensagem');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Conversa não encontrada');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao enviar mensagem: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Marca mensagens como lidas
  static Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await ApiService.dio.put('/conversations/$conversationId/read');
      
      // Notificar via WebSocket
      _channel?.sink.add(jsonEncode({
        'type': 'mark_read',
        'conversationId': conversationId,
        'userId': _currentUserId,
      }));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Conversa não encontrada');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao marcar mensagens como lidas: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Obtém mensagens de uma conversa com paginação
  static Future<List<ChatMessage>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiService.dio.get('/messages', queryParameters: {
        'conversationId': conversationId,
        'page': page,
        'limit': limit,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      throw Exception('Erro ao carregar mensagens');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Conversa não encontrada');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro ao carregar mensagens: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Entra em uma conversa (para receber mensagens em tempo real)
  static void joinConversation(String conversationId) {
    _currentConversationId = conversationId;
    _channel?.sink.add(jsonEncode({
      'type': 'join_conversation',
      'conversationId': conversationId,
    }));
  }

  /// Sai de uma conversa
  static void leaveConversation() {
    if (_currentConversationId != null) {
      _channel?.sink.add(jsonEncode({
        'type': 'leave_conversation',
        'conversationId': _currentConversationId,
      }));
      _currentConversationId = null;
    }
  }

  /// Desconecta do WebSocket e limpa recursos
  static Future<void> disconnect() async {
    _currentUserId = null;
    _currentConversationId = null;
    
    await _messageStreamController?.close();
    await _conversationStreamController?.close();
    _messageStreamController = null;
    _conversationStreamController = null;
    
    await _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  /// Verifica se está conectado ao WebSocket
  static bool get isConnected => _channel != null;

  /// Obtém o ID do usuário atual
  static String? get currentUserId => _currentUserId;

  /// Obtém o ID da conversa atual
  static String? get currentConversationId => _currentConversationId;
}
