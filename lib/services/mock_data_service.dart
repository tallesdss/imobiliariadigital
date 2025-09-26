import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/realtor_model.dart';
import '../models/property_model.dart';
import '../models/chat_model.dart';
import '../models/favorite_model.dart';

class MockDataService {
  static const Uuid _uuid = Uuid();

  // Mock Users
  static final List<User> _users = [
    User(
      id: 'user1',
      name: 'João Silva',
      email: 'joao@email.com',
      phone: '(11) 99999-1111',
      type: UserType.buyer,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    User(
      id: 'user2',
      name: 'Maria Santos',
      email: 'maria@email.com',
      phone: '(11) 99999-2222',
      type: UserType.buyer,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  // Mock Realtors
  static final List<Realtor> _realtors = [
    Realtor(
      id: 'realtor1',
      name: 'Carlos Oliveira',
      email: 'carlos@imobiliaria.com',
      phone: '(11) 99999-3333',
      creci: 'CRECI-SP 12345',
      bio: 'Corretor especializado em imóveis residenciais na zona sul de São Paulo.',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      totalProperties: 25,
      soldProperties: 18,
    ),
    Realtor(
      id: 'realtor2',
      name: 'Ana Costa',
      email: 'ana@imobiliaria.com',
      phone: '(11) 99999-4444',
      creci: 'CRECI-SP 67890',
      bio: 'Especialista em imóveis comerciais e de alto padrão.',
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      totalProperties: 15,
      soldProperties: 12,
    ),
  ];

  // Mock Properties
  static final List<Property> _properties = [
    Property(
      id: 'prop1',
      title: 'Apartamento 3 quartos - Vila Madalena',
      description: 'Lindo apartamento de 3 quartos, 2 banheiros, sala ampla com varanda. Prédio com portaria 24h, academia e piscina.',
      price: 850000.00,
      type: PropertyType.apartment,
      status: PropertyStatus.active,
      address: 'Rua Harmonia, 123',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '05435-000',
      photos: [
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
        'https://images.unsplash.com/photo-1560449752-0b2b4b9b7e2d?w=800',
      ],
      videos: [],
      attributes: {
        'bedrooms': 3,
        'bathrooms': 2,
        'area': 85,
        'parking': 2,
        'floor': 8,
      },
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      realtorPhone: '(11) 99999-3333',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isFeatured: true,
    ),
    Property(
      id: 'prop2',
      title: 'Casa 4 quartos - Jardins',
      description: 'Casa térrea com 4 quartos, 3 banheiros, sala de estar, sala de jantar, cozinha ampla, quintal com churrasqueira.',
      price: 1200000.00,
      type: PropertyType.house,
      status: PropertyStatus.active,
      address: 'Rua Augusta, 456',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01305-000',
      photos: [
        'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
      ],
      videos: [],
      attributes: {
        'bedrooms': 4,
        'bathrooms': 3,
        'area': 200,
        'parking': 3,
        'land_area': 300,
      },
      realtorId: 'realtor2',
      realtorName: 'Ana Costa',
      realtorPhone: '(11) 99999-4444',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isFeatured: false,
    ),
    Property(
      id: 'prop3',
      title: 'Loft Studio - Pinheiros',
      description: 'Loft moderno tipo studio, mobiliado, com cozinha americana e banheiro. Ideal para jovens profissionais.',
      price: 450000.00,
      type: PropertyType.apartment,
      status: PropertyStatus.active,
      address: 'Rua dos Pinheiros, 789',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '05422-000',
      photos: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        'https://images.unsplash.com/photo-1560448075-cbc16bb4af8e?w=800',
      ],
      videos: [],
      attributes: {
        'bedrooms': 1,
        'bathrooms': 1,
        'area': 45,
        'parking': 1,
        'floor': 5,
      },
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      realtorPhone: '(11) 99999-3333',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      isFeatured: false,
    ),
    Property(
      id: 'prop4',
      title: 'Sala Comercial - Centro',
      description: 'Sala comercial de 60m² no centro da cidade, com 2 banheiros, recepção e copa. Prédio comercial com elevador.',
      price: 320000.00,
      type: PropertyType.commercial,
      status: PropertyStatus.sold,
      address: 'Av. Paulista, 1000',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01310-100',
      photos: [
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
        'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800',
      ],
      videos: [],
      attributes: {
        'area': 60,
        'bathrooms': 2,
        'parking': 1,
        'floor': 12,
      },
      realtorId: 'realtor2',
      realtorName: 'Ana Costa',
      realtorPhone: '(11) 99999-4444',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isFeatured: false,
    ),
  ];

  // Mock Favorites
  static final List<Favorite> _favorites = [
    Favorite(
      id: 'fav1',
      userId: 'user1',
      propertyId: 'prop1',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Favorite(
      id: 'fav2',
      userId: 'user1',
      propertyId: 'prop3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Mock Alerts
  static final List<PropertyAlert> _alerts = [
    PropertyAlert(
      id: 'alert1',
      userId: 'user1',
      propertyId: 'prop2',
      propertyTitle: 'Casa 4 quartos - Jardins',
      type: AlertType.priceReduction,
      targetPrice: 1100000.00,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // Mock Chat Messages
  static final List<ChatMessage> _chatMessages = [
    ChatMessage(
      id: 'msg1',
      senderId: 'user1',
      senderName: 'João Silva',
      content: 'Olá! Gostaria de mais informações sobre este apartamento.',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    ChatMessage(
      id: 'msg2',
      senderId: 'realtor1',
      senderName: 'Carlos Oliveira',
      content: 'Olá João! Fico feliz com seu interesse. O apartamento está disponível para visita. Quando seria melhor para você?',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    ChatMessage(
      id: 'msg3',
      senderId: 'user1',
      senderName: 'João Silva',
      content: 'Poderia ser amanhã pela manhã?',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
  ];

  // Mock Conversations
  static final List<ChatConversation> _conversations = [
    ChatConversation(
      id: 'conv1',
      propertyId: 'prop1',
      propertyTitle: 'Apartamento 3 quartos - Vila Madalena',
      buyerId: 'user1',
      buyerName: 'João Silva',
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      messages: _chatMessages,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadCount: 1,
    ),
  ];

  // Getters
  static List<User> get users => List.unmodifiable(_users);
  static List<Realtor> get realtors => List.unmodifiable(_realtors);
  static List<Property> get properties => List.unmodifiable(_properties);
  static List<Property> get activeProperties => 
      _properties.where((p) => p.status == PropertyStatus.active).toList();
  static List<Favorite> get favorites => List.unmodifiable(_favorites);
  static List<PropertyAlert> get alerts => List.unmodifiable(_alerts);
  static List<ChatConversation> get conversations => List.unmodifiable(_conversations);

  // Methods
  static User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  static Realtor? getRealtorById(String id) {
    try {
      return _realtors.firstWhere((realtor) => realtor.id == id);
    } catch (e) {
      return null;
    }
  }

  static Property? getPropertyById(String id) {
    try {
      return _properties.firstWhere((property) => property.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Property> getPropertiesByRealtor(String realtorId) {
    return _properties.where((p) => p.realtorId == realtorId).toList();
  }

  static List<Property> getFavoriteProperties(String userId) {
    final userFavorites = _favorites.where((f) => f.userId == userId);
    return userFavorites
        .map((f) => getPropertyById(f.propertyId))
        .where((p) => p != null)
        .cast<Property>()
        .toList();
  }

  static List<PropertyAlert> getUserAlerts(String userId) {
    return _alerts.where((a) => a.userId == userId && a.isActive).toList();
  }

  static List<ChatConversation> getUserConversations(String userId, UserType userType) {
    if (userType == UserType.buyer) {
      return _conversations.where((c) => c.buyerId == userId).toList();
    } else if (userType == UserType.realtor) {
      return _conversations.where((c) => c.realtorId == userId).toList();
    }
    return _conversations; // Admin sees all
  }

  static bool isPropertyFavorited(String userId, String propertyId) {
    return _favorites.any((f) => f.userId == userId && f.propertyId == propertyId);
  }

  // Add methods (simulate API calls)
  static String addProperty(Property property) {
    final newProperty = property.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _properties.add(newProperty);
    return newProperty.id;
  }

  static void updateProperty(Property property) {
    final index = _properties.indexWhere((p) => p.id == property.id);
    if (index != -1) {
      _properties[index] = property.copyWith(updatedAt: DateTime.now());
    }
  }

  static void deleteProperty(String propertyId) {
    _properties.removeWhere((p) => p.id == propertyId);
  }

  static String addFavorite(String userId, String propertyId) {
    final favorite = Favorite(
      id: _uuid.v4(),
      userId: userId,
      propertyId: propertyId,
      createdAt: DateTime.now(),
    );
    _favorites.add(favorite);
    return favorite.id;
  }

  static void removeFavorite(String userId, String propertyId) {
    _favorites.removeWhere((f) => f.userId == userId && f.propertyId == propertyId);
  }

  static String addAlert(PropertyAlert alert) {
    final newAlert = alert.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    _alerts.add(newAlert);
    return newAlert.id;
  }

  static void removeAlert(String alertId) {
    _alerts.removeWhere((a) => a.id == alertId);
  }

  static String addRealtor(Realtor realtor) {
    final newRealtor = realtor.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    _realtors.add(newRealtor);
    return newRealtor.id;
  }

  static void updateRealtor(Realtor realtor) {
    final index = _realtors.indexWhere((r) => r.id == realtor.id);
    if (index != -1) {
      _realtors[index] = realtor;
    }
  }

  static void deleteRealtor(String realtorId) {
    _realtors.removeWhere((r) => r.id == realtorId);
    // Also remove their properties
    _properties.removeWhere((p) => p.realtorId == realtorId);
  }

  static void addChatMessage(String conversationId, ChatMessage message) {
    final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      final newMessage = message.copyWith(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
      );
      _conversations[convIndex].messages.add(newMessage);
    }
  }
}
