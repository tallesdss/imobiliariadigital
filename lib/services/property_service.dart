import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import 'supabase_service.dart';
import '../config/supabase_config.dart';
import 'mock_data_service.dart';

class PropertyService {
  static Future<List<Property>> getProperties({
    String? search,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Tentar buscar do Supabase primeiro
      try {
        final response = await SupabaseService.client
            .from(SupabaseConfig.propertiesTable)
            .select('*')
            .eq('status', 'ativo')
            .order('data_criacao', ascending: false)
            .range((page - 1) * limit, page * limit - 1);
        
        return response.map((json) => Property.fromJson(json)).toList();
      } catch (supabaseError) {
        if (kDebugMode) {
          debugPrint('Erro ao buscar do Supabase: $supabaseError');
          debugPrint('Usando dados mock...');
        }
        
        // Fallback para dados mock
        return MockDataService.activeProperties;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar imóveis: $e');
      }
      throw Exception('Erro de conexão. Tente novamente.');
    }
  }

  static Future<List<Property>> getAllProperties({
    String? search,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      // Tentar buscar do Supabase primeiro
      try {
        // Usar o método getProperties com limite muito alto para obter todos os imóveis
        return await getProperties(
          search: search,
          type: type,
          city: city,
          minPrice: minPrice,
          maxPrice: maxPrice,
          page: 1,
          limit: 1000, // Limite alto para obter todos os imóveis
        );
      } catch (supabaseError) {
        if (kDebugMode) {
          debugPrint('Erro ao buscar do Supabase: $supabaseError');
          debugPrint('Usando dados mock...');
        }
        
        // Fallback para dados mock
        return MockDataService.activeProperties;
      }
    } catch (e) {
      throw Exception('Erro ao carregar todos os imóveis: $e');
    }
  }

  static Future<Property> getPropertyById(String id) async {
    try {
      if (kDebugMode) {
        debugPrint('Buscando imóvel com ID: $id');
      }
      
      // Tentar buscar do Supabase primeiro
      try {
        final response = await SupabaseService.client
            .from(SupabaseConfig.propertiesTable)
            .select('*')
            .eq('id', id)
            .single();
        
        if (kDebugMode) {
          debugPrint('Dados recebidos do Supabase: $response');
        }
        
        final property = Property.fromJson(response);
        
        if (kDebugMode) {
          debugPrint('Property criado: ${property.title}');
        }
        
        return property;
      } catch (supabaseError) {
        if (kDebugMode) {
          debugPrint('Erro ao buscar do Supabase: $supabaseError');
          debugPrint('Tentando buscar dados mock...');
        }
        
        // Fallback para dados mock
        final mockProperty = MockDataService.getPropertyById(id);
        if (mockProperty != null) {
          if (kDebugMode) {
            debugPrint('Property encontrado nos dados mock: ${mockProperty.title}');
          }
          return mockProperty;
        } else {
          throw Exception('Imóvel não encontrado');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao buscar imóvel por ID: $e');
        debugPrint('Tipo do erro: ${e.runtimeType}');
      }
      throw Exception('Erro de conexão. Tente novamente.');
    }
  }

  static Future<List<Property>> getFeaturedProperties() async {
    try {
      // Tentar buscar do Supabase primeiro
      try {
        final response = await SupabaseService.client
            .from(SupabaseConfig.propertiesTable)
            .select('*')
            .eq('status', 'ativo')
            .eq('destaque', true)
            .order('data_criacao', ascending: false);
        
        return response.map((json) => Property.fromJson(json)).toList();
      } catch (supabaseError) {
        if (kDebugMode) {
          debugPrint('Erro ao buscar do Supabase: $supabaseError');
          debugPrint('Usando dados mock...');
        }
        
        // Fallback para dados mock
        return MockDataService.activeProperties.where((p) => p.isFeatured).toList();
      }
    } catch (e) {
      throw Exception('Erro ao carregar imóveis em destaque: $e');
    }
  }

  static Future<List<Property>> getLaunchProperties() async {
    try {
      // Tentar buscar do Supabase primeiro
      try {
        final response = await SupabaseService.client
            .from(SupabaseConfig.propertiesTable)
            .select('*')
            .eq('status', 'ativo')
            .eq('lancamento', true)
            .order('data_criacao', ascending: false);
        
        return response.map((json) => Property.fromJson(json)).toList();
      } catch (supabaseError) {
        if (kDebugMode) {
          debugPrint('Erro ao buscar do Supabase: $supabaseError');
          debugPrint('Usando dados mock...');
        }
        
        // Fallback para dados mock
        return MockDataService.activeProperties.where((p) => p.isLaunch).toList();
      }
    } catch (e) {
      throw Exception('Erro ao carregar lançamentos: $e');
    }
  }

  static Future<List<Property>> getPropertiesByType(PropertyType type) async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConfig.propertiesTable)
          .select('*')
          .eq('status', 'ativo')
          .eq('tipo_imovel', _getTypeString(type))
          .order('data_criacao', ascending: false)
          .limit(10);
      
      return response.map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar imóveis por tipo: $e');
    }
  }

  static Future<List<String>> getCities() async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConfig.propertiesTable)
          .select('cidade')
          .eq('status', 'ativo');
      
      final cities = response
          .map((row) => row['cidade'] as String)
          .toSet()
          .toList()
        ..sort();
      
      return cities;
    } catch (e) {
      throw Exception('Erro ao carregar cidades: $e');
    }
  }

  static Future<Map<String, int>> getPropertyStats() async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConfig.propertiesTable)
          .select('tipo_imovel, destaque, lancamento')
          .eq('status', 'ativo');
      
      final properties = response.map((row) => {
        'type': row['tipo_imovel'] as String,
        'is_featured': row['destaque'] as bool? ?? false,
        'is_launch': row['lancamento'] as bool? ?? false,
      }).toList();
      
      return {
        'total': properties.length,
        'apartments': properties.where((p) => p['type'] == 'apartamento').length,
        'houses': properties.where((p) => p['type'] == 'casa').length,
        'commercial': properties.where((p) => p['type'] == 'comercial').length,
        'land': properties.where((p) => p['type'] == 'terreno').length,
        'featured': properties.where((p) => p['is_featured'] == true).length,
        'launches': properties.where((p) => p['is_launch'] == true).length,
      };
    } catch (e) {
      throw Exception('Erro ao carregar estatísticas: $e');
    }
  }

  /// Cria um novo imóvel
  static Future<Property> createProperty(Property property) async {
    try {
      final propertyData = _propertyToJson(property);
      
      final response = await SupabaseService.client
          .from(SupabaseConfig.propertiesTable)
          .insert(propertyData)
          .select()
          .single();
      
      return Property.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao criar imóvel: $e');
      }
      throw Exception('Erro ao criar imóvel. Tente novamente.');
    }
  }

  /// Atualiza um imóvel existente
  static Future<Property> updateProperty(Property property) async {
    try {
      final propertyData = _propertyToJson(property);
      
      final response = await SupabaseService.client
          .from(SupabaseConfig.propertiesTable)
          .update(propertyData)
          .eq('id', property.id)
          .select()
          .single();
      
      return Property.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao atualizar imóvel: $e');
      }
      throw Exception('Erro ao atualizar imóvel. Tente novamente.');
    }
  }

  /// Remove um imóvel (soft delete - marca como arquivado)
  static Future<void> deleteProperty(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseConfig.propertiesTable)
          .update({
            'status': 'arquivado',
            'data_atualizacao': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao remover imóvel: $e');
      }
      throw Exception('Erro ao remover imóvel. Tente novamente.');
    }
  }

  /// Converte Property para formato do banco de dados
  static Map<String, dynamic> _propertyToJson(Property property) {
    return {
      'id': property.id,
      'titulo': property.title,
      'descricao': property.description,
      'preco': property.price,
      'tipo_imovel': _getTypeString(property.type),
      'status': _getStatusString(property.status),
      'tipo_transacao': property.transactionType != null ? _getTransactionTypeString(property.transactionType!) : null,
      'endereco': property.address,
      'cidade': property.city,
      'estado': property.state,
      'cep': property.zipCode,
      'bairro': property.neighborhood,
      'fotos': property.photos,
      'videos': property.videos,
      'atributos': property.attributes,
      'corretor_id': property.realtorId,
      'nome_corretor': property.realtorName,
      'telefone_corretor': property.realtorPhone,
      'contato_admin': property.adminContact,
      'data_criacao': property.createdAt.toIso8601String(),
      'data_atualizacao': property.updatedAt.toIso8601String(),
      'destaque': property.isFeatured,
      'lancamento': property.isLaunch,
    };
  }

  static String _getTypeString(PropertyType type) {
    switch (type) {
      case PropertyType.house:
        return 'casa';
      case PropertyType.apartment:
        return 'apartamento';
      case PropertyType.commercial:
        return 'comercial';
      case PropertyType.land:
        return 'terreno';
    }
  }

  static String _getStatusString(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.active:
        return 'ativo';
      case PropertyStatus.sold:
        return 'vendido';
      case PropertyStatus.archived:
        return 'arquivado';
      case PropertyStatus.suspended:
        return 'suspenso';
    }
  }

  static String _getTransactionTypeString(PropertyTransactionType transactionType) {
    switch (transactionType) {
      case PropertyTransactionType.sale:
        return 'venda';
      case PropertyTransactionType.rent:
        return 'aluguel';
      case PropertyTransactionType.daily:
        return 'temporada';
    }
  }
}