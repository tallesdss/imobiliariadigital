import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/favorite_model.dart';
import '../models/property_model.dart';
import 'api_service.dart';

class FavoriteService {
  static const String _favoritesCacheKey = 'user_favorites_cache';
  
  // Cache local para melhor performance
  static final Map<String, bool> _favoritesStatusCache = {};
  static List<Property>? _cachedFavorites;

  static Future<List<Property>> getUserFavorites() async {
    try {
      final response = await ApiService.dio.get('/favorites');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['properties'] ?? response.data;
        final favorites = data.map((json) => Property.fromJson(json)).toList();
        
        // Salvar no cache local
        _cachedFavorites = favorites;
        await _saveFavoritesToCache(favorites);
        
        return favorites;
      }
      throw Exception('Erro ao carregar favoritos');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Retorna lista vazia se não encontrar favoritos
      } else {
        // Tentar carregar do cache em caso de erro de conexão
        final cachedFavorites = await _loadFavoritesFromCache();
        if (cachedFavorites != null) {
          return cachedFavorites;
        }
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      // Tentar carregar do cache em caso de erro
      final cachedFavorites = await _loadFavoritesFromCache();
      if (cachedFavorites != null) {
        return cachedFavorites;
      }
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<bool> isPropertyFavorited(String propertyId) async {
    // Verificar cache primeiro
    if (_favoritesStatusCache.containsKey(propertyId)) {
      return _favoritesStatusCache[propertyId]!;
    }
    
    try {
      final response = await ApiService.dio.get('/favorites/$propertyId');
      
      if (response.statusCode == 200) {
        final isFavorited = response.data['isFavorited'] ?? false;
        _favoritesStatusCache[propertyId] = isFavorited;
        return isFavorited;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _favoritesStatusCache[propertyId] = false;
        return false; // Não é favorito se não encontrar
      } else {
        // Tentar verificar no cache local
        final cachedFavorites = await _loadFavoritesFromCache();
        if (cachedFavorites != null) {
          final isFavorited = cachedFavorites.any((p) => p.id == propertyId);
          _favoritesStatusCache[propertyId] = isFavorited;
          return isFavorited;
        }
        throw Exception('Erro de conexão. Tente novamente.');
      }
    } catch (e) {
      // Tentar verificar no cache local
      final cachedFavorites = await _loadFavoritesFromCache();
      if (cachedFavorites != null) {
        final isFavorited = cachedFavorites.any((p) => p.id == propertyId);
        _favoritesStatusCache[propertyId] = isFavorited;
        return isFavorited;
      }
      throw Exception('Erro inesperado: $e');
    }
  }

  static Future<Favorite> addFavorite(String propertyId) async {
    try {
      final response = await ApiService.dio.post('/favorites', data: {
        'propertyId': propertyId,
      });
      
      if (response.statusCode == 201) {
        final favorite = Favorite.fromJson(response.data);
        
        // Atualizar cache
        _favoritesStatusCache[propertyId] = true;
        await _clearFavoritesCache(); // Limpar cache para forçar reload
        
        return favorite;
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
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Atualizar cache
        _favoritesStatusCache[propertyId] = false;
        await _clearFavoritesCache(); // Limpar cache para forçar reload
      } else {
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

  // Métodos auxiliares para cache
  static Future<void> _saveFavoritesToCache(List<Property> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = favorites.map((p) => p.toJson()).toList();
      await prefs.setString(_favoritesCacheKey, jsonEncode(favoritesJson));
    } catch (e) {
      // Ignorar erros de cache
    }
  }

  static Future<List<Property>?> _loadFavoritesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesCacheKey);
      if (favoritesJson != null) {
        final List<dynamic> data = jsonDecode(favoritesJson);
        return data.map((json) => Property.fromJson(json)).toList();
      }
    } catch (e) {
      // Ignorar erros de cache
    }
    return null;
  }

  static Future<void> _clearFavoritesCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesCacheKey);
      _cachedFavorites = null;
    } catch (e) {
      // Ignorar erros de cache
    }
  }

  // Método para limpar todo o cache (útil para logout)
  static Future<void> clearAllCache() async {
    _favoritesStatusCache.clear();
    _cachedFavorites = null;
    await _clearFavoritesCache();
  }

  // Método para obter favoritos do cache sem fazer requisição
  static List<Property>? getCachedFavorites() {
    return _cachedFavorites;
  }

  // Método para verificar se um imóvel é favorito usando apenas cache
  static bool? isPropertyFavoritedFromCache(String propertyId) {
    return _favoritesStatusCache[propertyId];
  }
}
