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
      bio:
          'Corretor especializado em imóveis residenciais na zona sul de São Paulo.',
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
      description:
          'Lindo apartamento de 3 quartos, 2 banheiros, sala ampla com varanda. Prédio com portaria 24h, academia e piscina.',
      price: 850000.00,
      type: PropertyType.apartment,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.sale,
      address: 'Rua Harmonia, 123',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '05435-000',
      neighborhood: 'Vila Madalena',
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
        'parkingSpaces': 2,
        'floor': 8,
        'condominium': 850.0,
        'iptu': 450.0,
        'acceptsProposal': true,
        'hasFinancing': true,
        'hasGarage': true,
        'furnished': false,
        'petFriendly': true,
        'hasSecurity': true,
        'hasSwimmingPool': true,
        'hasGym': true,
      },
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      realtorPhone: '(11) 99999-3333',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isFeatured: true,
      isLaunch: true,
    ),
    Property(
      id: 'prop2',
      title: 'Casa 4 quartos - Jardins',
      description:
          'Casa térrea com 4 quartos, 3 banheiros, sala de estar, sala de jantar, cozinha ampla, quintal com churrasqueira.',
      price: 1200000.00,
      type: PropertyType.house,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.sale,
      address: 'Rua Augusta, 456',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01305-000',
      neighborhood: 'Jardins',
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
        'parkingSpaces': 3,
        'land_area': 300,
        'condominium': 0.0, // Casa não tem condomínio
        'iptu': 1200.0,
        'acceptsProposal': false,
        'hasFinancing': true,
        'hasGarage': true,
        'furnished': false,
        'petFriendly': true,
        'hasSecurity': false,
        'hasSwimmingPool': false,
        'hasGym': false,
      },
      realtorId: 'realtor2',
      realtorName: 'Ana Costa',
      realtorPhone: '(11) 99999-4444',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isFeatured: false,
      isLaunch: false,
    ),
    Property(
      id: 'prop3',
      title: 'Loft Studio - Pinheiros',
      description:
          'Loft moderno tipo studio, mobiliado, com cozinha americana e banheiro. Ideal para jovens profissionais.',
      price: 2500.00,
      type: PropertyType.apartment,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.rent,
      address: 'Rua dos Pinheiros, 789',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '05422-000',
      neighborhood: 'Pinheiros',
      photos: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        'https://images.unsplash.com/photo-1560448075-cbc16bb4af8e?w=800',
      ],
      videos: [],
      attributes: {
        'bedrooms': 1,
        'bathrooms': 1,
        'area': 45,
        'parkingSpaces': 1,
        'floor': 5,
        'condominium': 650.0,
        'iptu': 280.0,
        'acceptsProposal': true,
        'hasFinancing': false,
        'hasGarage': true,
        'furnished': true,
        'petFriendly': false,
        'hasSecurity': true,
        'hasSwimmingPool': false,
        'hasGym': true,
      },
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      realtorPhone: '(11) 99999-3333',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      isFeatured: false,
      isLaunch: false,
    ),
    Property(
      id: 'prop4',
      title: 'Sala Comercial - Centro',
      description:
          'Sala comercial de 60m² no centro da cidade, com 2 banheiros, recepção e copa. Prédio comercial com elevador.',
      price: 320000.00,
      type: PropertyType.commercial,
      status: PropertyStatus.sold,
      transactionType: PropertyTransactionType.sale,
      address: 'Av. Paulista, 1000',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01310-100',
      neighborhood: 'Centro',
      photos: [
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
        'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800',
      ],
      videos: [],
      attributes: {
        'area': 60, 
        'bathrooms': 2, 
        'parkingSpaces': 1, 
        'floor': 12,
        'condominium': 1200.0,
        'iptu': 800.0,
        'acceptsProposal': false,
        'hasFinancing': true,
        'hasGarage': true,
        'furnished': false,
        'petFriendly': false,
        'hasSecurity': true,
        'hasSwimmingPool': false,
        'hasGym': false,
      },
      realtorId: 'realtor2',
      realtorName: 'Ana Costa',
      realtorPhone: '(11) 99999-4444',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isFeatured: false,
      isLaunch: false,
    ),
    Property(
      id: 'prop5',
      title: 'Residencial Vista Verde - LANÇAMENTO',
      description:
          'Novo lançamento! Apartamentos de 2 e 3 quartos com varanda gourmet. Área de lazer completa com piscina, academia e playground.',
      price: 680000.00,
      type: PropertyType.apartment,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.sale,
      address: 'Av. das Nações, 2500',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '04794-000',
      neighborhood: 'Vila Olímpia',
      photos: [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
      ],
      videos: [
        'https://sample-videos.com/zip/10/mp4/SampleVideo_360x240_1mb.mp4',
      ],
      attributes: {
        'bedrooms': 3,
        'bathrooms': 2,
        'area': 78,
        'parkingSpaces': 2,
        'floor': 15,
        'condominium': 950.0,
        'iptu': 520.0,
        'acceptsProposal': true,
        'hasFinancing': true,
        'hasGarage': true,
        'furnished': false,
        'petFriendly': true,
        'hasSecurity': true,
        'hasSwimmingPool': true,
        'hasGym': true,
      },
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      realtorPhone: '(11) 99999-3333',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      isFeatured: true,
      isLaunch: true,
    ),
    Property(
      id: 'prop6',
      title: 'Condomínio Harmony - LANÇAMENTO',
      description:
          'Casas em condomínio fechado com segurança 24h. 3 quartos, suíte master, jardim privativo e área gourmet.',
      price: 950000.00,
      type: PropertyType.house,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.sale,
      address: 'Rua dos Eucaliptos, 100',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '05654-070',
      neighborhood: 'Morumbi',
      photos: [
        'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      ],
      videos: [],
      attributes: {
        'bedrooms': 3,
        'bathrooms': 3,
        'area': 180,
        'parkingSpaces': 2,
        'land_area': 250,
        'condominium': 0.0, // Casa em condomínio fechado
        'iptu': 950.0,
        'acceptsProposal': false,
        'hasFinancing': true,
        'hasGarage': true,
        'furnished': false,
        'petFriendly': true,
        'hasSecurity': true,
        'hasSwimmingPool': true,
        'hasGym': true,
      },
      realtorId: 'realtor2',
      realtorName: 'Ana Costa',
      realtorPhone: '(11) 99999-4444',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      isFeatured: true,
      isLaunch: true,
    ),
    Property(
      id: 'prop7',
      title: 'Sobrado Moderno - Moema',
      description:
          'Sobrado com 4 suítes, escritório, sala de estar e jantar integradas, cozinha gourmet, quintal com piscina.',
      price: 8500.00,
      type: PropertyType.house,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.rent,
      address: 'Rua Ibirapuera, 567',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '04029-000',
      neighborhood: 'Moema',
      photos: [
        'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      ],
      videos: [],
      attributes: {
        'bedrooms': 4,
        'bathrooms': 5,
        'area': 350,
        'parkingSpaces': 4,
        'land_area': 400,
        'condominium': 0.0, // Casa não tem condomínio
        'iptu': 1800.0,
        'acceptsProposal': true,
        'hasFinancing': true,
        'hasGarage': true,
        'furnished': false,
        'petFriendly': true,
        'hasSecurity': false,
        'hasSwimmingPool': true,
        'hasGym': false,
      },
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      realtorPhone: '(11) 99999-3333',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isFeatured: false,
      isLaunch: false,
    ),
    Property(
      id: 'prop8',
      title: 'Terreno Comercial - Brooklin',
      description:
          'Terreno comercial de 500m² em localização privilegiada. Ideal para construção de edifício comercial ou residencial.',
      price: 1200000.00,
      type: PropertyType.land,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.sale,
      address: 'Av. Engenheiro Luis Carlos Berrini, 800',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '04571-000',
      neighborhood: 'Brooklin',
      photos: [
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
      ],
      videos: [],
      attributes: {
        'area': 500, 
        'zoning': 'Comercial/Residencial',
        'condominium': 0.0, // Terreno não tem condomínio
        'iptu': 2000.0,
        'acceptsProposal': true,
        'hasFinancing': false,
        'hasGarage': false,
        'furnished': false,
        'petFriendly': false,
        'hasSecurity': false,
        'hasSwimmingPool': false,
        'hasGym': false,
      },
      realtorId: 'realtor2',
      realtorName: 'Ana Costa',
      realtorPhone: '(11) 99999-4444',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      isFeatured: false,
      isLaunch: false,
    ),
    // Imóveis adicionais para melhorar variedade dos filtros
    Property(
      id: 'prop9',
      title: 'Apartamento 2 quartos - Copacabana',
      description:
          'Apartamento de 2 quartos com vista para o mar, mobiliado, ideal para temporada. Prédio com portaria 24h.',
      price: 1800.00,
      type: PropertyType.apartment,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.daily,
      address: 'Av. Atlântica, 2000',
      city: 'Rio de Janeiro',
      state: 'RJ',
      zipCode: '22021-001',
      neighborhood: 'Copacabana',
      photos: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        'https://images.unsplash.com/photo-1560448075-cbc16bb4af8e?w=800',
      ],
      videos: [],
      attributes: {
        'bedrooms': 2,
        'bathrooms': 1,
        'area': 65,
        'parkingSpaces': 1,
        'floor': 10,
        'condominium': 800.0,
        'iptu': 350.0,
        'acceptsProposal': true,
        'hasFinancing': false,
        'hasGarage': true,
        'furnished': true,
        'petFriendly': false,
        'hasSecurity': true,
        'hasSwimmingPool': true,
        'hasGym': false,
      },
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      realtorPhone: '(11) 99999-3333',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      isFeatured: false,
      isLaunch: false,
    ),
    Property(
      id: 'prop10',
      title: 'Casa 5 quartos - Alphaville',
      description:
          'Casa de alto padrão com 5 suítes, piscina, quadra de tênis, jardim paisagístico. Condomínio fechado com segurança 24h.',
      price: 2500000.00,
      type: PropertyType.house,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.sale,
      address: 'Rua das Palmeiras, 500',
      city: 'Barueri',
      state: 'SP',
      zipCode: '06454-000',
      neighborhood: 'Alphaville',
      photos: [
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      ],
      videos: [],
      attributes: {
        'bedrooms': 5,
        'bathrooms': 6,
        'area': 450,
        'parkingSpaces': 6,
        'land_area': 800,
        'condominium': 0.0,
        'iptu': 2500.0,
        'acceptsProposal': false,
        'hasFinancing': true,
        'hasGarage': true,
        'furnished': false,
        'petFriendly': true,
        'hasSecurity': true,
        'hasSwimmingPool': true,
        'hasGym': true,
      },
      realtorId: 'realtor2',
      realtorName: 'Ana Costa',
      realtorPhone: '(11) 99999-4444',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isFeatured: true,
      isLaunch: false,
    ),
    Property(
      id: 'prop11',
      title: 'Kitnet Mobiliada - Higienópolis',
      description:
          'Kitnet totalmente mobiliada, ideal para estudantes ou profissionais. Prédio com academia e lavanderia.',
      price: 1200.00,
      type: PropertyType.apartment,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.rent,
      address: 'Rua da Consolação, 3000',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01416-000',
      neighborhood: 'Higienópolis',
      photos: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      ],
      videos: [],
      attributes: {
        'bedrooms': 1,
        'bathrooms': 1,
        'area': 35,
        'parkingSpaces': 0,
        'floor': 3,
        'condominium': 400.0,
        'iptu': 200.0,
        'acceptsProposal': true,
        'hasFinancing': false,
        'hasGarage': false,
        'furnished': true,
        'petFriendly': false,
        'hasSecurity': true,
        'hasSwimmingPool': false,
        'hasGym': true,
      },
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      realtorPhone: '(11) 99999-3333',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isFeatured: false,
      isLaunch: false,
    ),
    Property(
      id: 'prop12',
      title: 'Loja Comercial - Shopping Center',
      description:
          'Loja de 80m² em shopping center, com vitrine, estoque e banheiro. Localização privilegiada no piso térreo.',
      price: 15000.00,
      type: PropertyType.commercial,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.rent,
      address: 'Av. Paulista, 2000',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01310-300',
      neighborhood: 'Bela Vista',
      photos: [
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
      ],
      videos: [],
      attributes: {
        'area': 80,
        'bathrooms': 1,
        'parkingSpaces': 0,
        'floor': 1,
        'condominium': 2000.0,
        'iptu': 600.0,
        'acceptsProposal': false,
        'hasFinancing': false,
        'hasGarage': false,
        'furnished': false,
        'petFriendly': false,
        'hasSecurity': true,
        'hasSwimmingPool': false,
        'hasGym': false,
      },
      realtorId: 'realtor2',
      realtorName: 'Ana Costa',
      realtorPhone: '(11) 99999-4444',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      isFeatured: false,
      isLaunch: false,
    ),
    Property(
      id: 'prop13',
      title: 'Terreno Residencial - Granja Viana',
      description:
          'Terreno residencial de 1000m² em condomínio fechado. Ideal para construção de casa de alto padrão.',
      price: 800000.00,
      type: PropertyType.land,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.sale,
      address: 'Rua das Flores, 100',
      city: 'Cotia',
      state: 'SP',
      zipCode: '06708-000',
      neighborhood: 'Granja Viana',
      photos: [
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
      ],
      videos: [],
      attributes: {
        'area': 1000,
        'zoning': 'Residencial',
        'condominium': 0.0,
        'iptu': 1200.0,
        'acceptsProposal': true,
        'hasFinancing': true,
        'hasGarage': false,
        'furnished': false,
        'petFriendly': false,
        'hasSecurity': true,
        'hasSwimmingPool': false,
        'hasGym': false,
      },
      realtorId: 'realtor1',
      realtorName: 'Carlos Oliveira',
      realtorPhone: '(11) 99999-3333',
      adminContact: '(11) 99999-0000',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      isFeatured: false,
      isLaunch: false,
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
      content:
          'Olá João! Fico feliz com seu interesse. O apartamento está disponível para visita. Quando seria melhor para você?',
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
  static List<ChatConversation> get conversations =>
      List.unmodifiable(_conversations);

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

  static List<ChatConversation> getUserConversations(
    String userId,
    UserType userType,
  ) {
    if (userType == UserType.buyer) {
      return _conversations.where((c) => c.buyerId == userId).toList();
    } else if (userType == UserType.realtor) {
      return _conversations.where((c) => c.realtorId == userId).toList();
    }
    return _conversations; // Admin sees all
  }

  static bool isPropertyFavorited(String userId, String propertyId) {
    return _favorites.any(
      (f) => f.userId == userId && f.propertyId == propertyId,
    );
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
    _favorites.removeWhere(
      (f) => f.userId == userId && f.propertyId == propertyId,
    );
  }

  static String addAlert(PropertyAlert alert) {
    final newAlert = alert.copyWith(id: _uuid.v4(), createdAt: DateTime.now());
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
      final conversation = _conversations[convIndex];
      final updatedMessages = List<ChatMessage>.from(conversation.messages)..add(newMessage);
      _conversations[convIndex] = conversation.copyWith(
        messages: updatedMessages,
        lastMessageAt: DateTime.now(),
      );
    }
  }
}
