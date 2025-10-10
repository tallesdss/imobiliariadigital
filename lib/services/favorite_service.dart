import 'package:dio/dio.dart';
import '../models/favorite_model.dart';
import '../models/property_model.dart';
import 'api_service.dart';

class FavoriteService {
  static Future<List<Property>> getUserFavorites() async {
    try {
      final response = await ApiService.dio.get('/favorites');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['properties'] ?? response.data;
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Erro ao carregar favoritos');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Retorna lista vazia se não encontrar favoritos
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<bool> isPropertyFavorited(String propertyId) async {
    try {
      final response = await ApiService.dio.get('/favorites/$propertyId');
      
      if (response.statusCode == 200) {
        return response.data['isFavorited'] ?? false;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false; // Não é favorito se não encontrar
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<Favorite> addFavorite(String propertyId) async {
    try {
      final response = await ApiService.dio.post('/favorites', data: {
        'propertyId': propertyId,
      });
      
      if (response.statusCode == 201) {
        return Favorite.fromJson(response.data);
      }
      throw Exception('Erro ao adicionar favorito');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Imóvel já está nos favoritos');
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<void> removeFavorite(String propertyId) async {
    try {
      final response = await ApiService.dio.delete('/favorites/$propertyId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao remover favorito');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Favorito não encontrado');
      } else {
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<void> toggleFavorite(String propertyId) async {
    try {
      final isFavorited = await isPropertyFavorited(propertyId);
      
      if (isFavorited) {
        await removeFavorite(propertyId);
      } else {
        await addFavorite(propertyId);
      }
    } catch (e) {
      throw Exception('Erro ao alterar favorito: $e');
    }
  }
}
