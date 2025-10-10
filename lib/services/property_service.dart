import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import 'supabase_service.dart';
import '../config/supabase_config.dart';

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
      final response = await SupabaseService.client
          .from(SupabaseConfig.propertiesTable)
          .select('*')
          .eq('status', 'ativo')
          .order('data_criacao', ascending: false)
          .range((page - 1) * limit, page * limit - 1);
      
      return response.map((json) => Property.fromJson(json)).toList();
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
    } catch (e) {
      throw Exception('Erro ao carregar todos os imóveis: $e');
    }
  }

  static Future<Property> getPropertyById(String id) async {
    try {
      if (kDebugMode) {
        debugPrint('Buscando imóvel com ID: $id');
      }
      
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
      final response = await SupabaseService.client
          .from(SupabaseConfig.propertiesTable)
          .select('*')
          .eq('status', 'ativo')
          .eq('destaque', true)
          .order('data_criacao', ascending: false);
      
      return response.map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar imóveis em destaque: $e');
    }
  }

  static Future<List<Property>> getLaunchProperties() async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConfig.propertiesTable)
          .select('*')
          .eq('status', 'ativo')
          .eq('lancamento', true)
          .order('data_criacao', ascending: false);
      
      return response.map((json) => Property.fromJson(json)).toList();
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
}