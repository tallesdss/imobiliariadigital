import 'package:dio/dio.dart';
import '../models/property_model.dart';
import 'api_service.dart';

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
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (type != null) {
        queryParams['type'] = type.name;
      }
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice;
      }

      final response = await ApiService.dio.get('/properties', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['properties'] ?? response.data;
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Erro ao carregar imóveis');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Retorna lista vazia se não encontrar imóveis
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<Property> getPropertyById(String id) async {
    try {
      final response = await ApiService.dio.get('/properties/$id');
      
      if (response.statusCode == 200) {
        return Property.fromJson(response.data);
      }
      throw Exception('Erro ao carregar imóvel');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Imóvel não encontrado');
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<List<Property>> getFeaturedProperties() async {
    try {
      final response = await ApiService.dio.get('/properties/featured');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['properties'] ?? response.data;
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Erro ao carregar imóveis em destaque');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Retorna lista vazia se não encontrar imóveis
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<List<Property>> getLaunchProperties() async {
    try {
      final response = await ApiService.dio.get('/properties/launches');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['properties'] ?? response.data;
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Erro ao carregar lançamentos');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Retorna lista vazia se não encontrar imóveis
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<List<Property>> getPropertiesByType(PropertyType type) async {
    try {
      final response = await ApiService.dio.get('/properties', queryParameters: {
        'type': type.name,
        'limit': 10,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['properties'] ?? response.data;
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Erro ao carregar imóveis por tipo');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Retorna lista vazia se não encontrar imóveis
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<List<String>> getCities() async {
    try {
      final response = await ApiService.dio.get('/properties/cities');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['cities'] ?? response.data;
        return data.cast<String>();
      }
      throw Exception('Erro ao carregar cidades');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Retorna lista vazia se não encontrar cidades
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<Map<String, int>> getPropertyStats() async {
    try {
      final response = await ApiService.dio.get('/properties/stats');
      
      if (response.statusCode == 200) {
        return Map<String, int>.from(response.data);
      }
      throw Exception('Erro ao carregar estatísticas');
    } on DioException {
      throw Exception('Erro de conexão. Tente novamente.');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
