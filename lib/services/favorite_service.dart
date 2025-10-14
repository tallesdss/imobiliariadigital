import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/favorite_model.dart';
import '../models/property_model.dart';
import '../models/alert_model.dart' as alert_models;
import 'api_service.dart';
import 'notification_service.dart';

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
        // Retorna lista vazia se não encontrar favoritos
        _cachedFavorites = [];
        await _saveFavoritesToCache([]);
        return [];
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.connectionError) {
        // Erro de conexão - tentar carregar do cache
        final cachedFavorites = await _loadFavoritesFromCache();
        if (cachedFavorites != null) {
          return cachedFavorites;
        }
        // Se não há cache, retorna lista vazia (usuário sem favoritos)
        return [];
      } else {
        // Outros erros - tentar cache
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
      // Se não há cache e é erro de conexão, retorna lista vazia
      if (e.toString().contains('connection') || e.toString().contains('timeout')) {
        return [];
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
      // Tentar usar API REST primeiro
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
        // Fallback para Supabase
        return await _checkFavoriteInSupabase(propertyId);
      }
    } catch (e) {
      // Fallback para Supabase
      return await _checkFavoriteInSupabase(propertyId);
    }
  }

  // Método auxiliar para verificar favorito no Supabase
  static Future<bool> _checkFavoriteInSupabase(String propertyId) async {
    try {
      // Por enquanto, retorna false como padrão
      // TODO: Implementar verificação de favoritos no Supabase quando necessário
      _favoritesStatusCache[propertyId] = false;
      return false;
    } catch (e) {
      // Em caso de erro, retorna false e tenta cache local
      final cachedFavorites = await _loadFavoritesFromCache();
      if (cachedFavorites != null) {
        final isFavorited = cachedFavorites.any((p) => p.id == propertyId);
        _favoritesStatusCache[propertyId] = isFavorited;
        return isFavorited;
      }
      // Se tudo falhar, retorna false
      _favoritesStatusCache[propertyId] = false;
      return false;
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

  // ===== INTEGRAÇÃO COM SISTEMA DE ALERTAS =====

  /// Cria alerta de redução de preço para um imóvel favorito
  static Future<String?> createPriceDropAlertForFavorite(
    String propertyId,
    String userId,
  ) async {
    try {
      final notificationService = NotificationService();
      
      // Criar critérios específicos para o imóvel
      final criteria = alert_models.AlertCriteria(
        // Critérios básicos que podem ser expandidos
        keywords: [propertyId], // Usar ID como identificador único
      );

      return await notificationService.createAlert(
        userId: userId,
        type: alert_models.AlertType.priceDrop,
        criteria: criteria,
        propertyId: propertyId,
      );
    } catch (e) {
      debugPrint('Erro ao criar alerta de preço para favorito: $e');
      return null;
    }
  }

  /// Cria alerta de mudança de status para um imóvel favorito
  static Future<String?> createStatusChangeAlertForFavorite(
    String propertyId,
    String userId,
  ) async {
    try {
      final notificationService = NotificationService();
      
      final criteria = alert_models.AlertCriteria(
        keywords: [propertyId],
      );

      return await notificationService.createAlert(
        userId: userId,
        type: alert_models.AlertType.statusChange,
        criteria: criteria,
        propertyId: propertyId,
      );
    } catch (e) {
      debugPrint('Erro ao criar alerta de status para favorito: $e');
      return null;
    }
  }

  /// Cria alerta baseado nas características de um imóvel favorito
  static Future<String?> createSimilarPropertyAlert(
    Property favoriteProperty,
    String userId,
  ) async {
    try {
      final notificationService = NotificationService();
      
      // Criar critérios baseados nas características do imóvel favorito
      final criteria = alert_models.AlertCriteria(
        city: favoriteProperty.city,
        neighborhood: favoriteProperty.neighborhood,
        propertyType: _mapPropertyType(favoriteProperty.type),
        minBedrooms: favoriteProperty.bedrooms,
        maxBedrooms: favoriteProperty.bedrooms,
        minBathrooms: favoriteProperty.bathrooms,
        maxBathrooms: favoriteProperty.bathrooms,
        minArea: favoriteProperty.area * 0.8,
        maxArea: favoriteProperty.area * 1.2,
        hasGarage: favoriteProperty.hasGarage,
        acceptsProposal: favoriteProperty.acceptsProposal,
        hasFinancing: favoriteProperty.hasFinancing,
        maxPrice: favoriteProperty.price * 1.1,
        minPrice: favoriteProperty.price * 0.8,
      );

      return await notificationService.createAlert(
        userId: userId,
        type: alert_models.AlertType.newProperty,
        criteria: criteria,
      );
    } catch (e) {
      debugPrint('Erro ao criar alerta de imóveis similares: $e');
      return null;
    }
  }

  /// Cria alertas automáticos para todos os favoritos
  static Future<List<String>> createAlertsForAllFavorites(String userId) async {
    try {
      final favorites = await getUserFavorites();
      final List<String> createdAlerts = [];

      for (final favorite in favorites) {
        // Criar alerta de redução de preço
        final priceAlertId = await createPriceDropAlertForFavorite(
          favorite.id,
          userId,
        );
        if (priceAlertId != null) {
          createdAlerts.add(priceAlertId);
        }

        // Criar alerta de mudança de status
        final statusAlertId = await createStatusChangeAlertForFavorite(
          favorite.id,
          userId,
        );
        if (statusAlertId != null) {
          createdAlerts.add(statusAlertId);
        }
      }

      return createdAlerts;
    } catch (e) {
      debugPrint('Erro ao criar alertas para favoritos: $e');
      return [];
    }
  }

  /// Remove alertas relacionados a um favorito quando ele é removido
  static Future<void> removeAlertsForFavorite(
    String propertyId,
    String userId,
  ) async {
    try {
      final notificationService = NotificationService();
      final userAlerts = await notificationService.getUserAlerts(userId);

      // Encontrar alertas relacionados ao imóvel
      final relatedAlerts = userAlerts.where((alert) =>
          alert.propertyId == propertyId ||
          (alert.criteria.keywords?.contains(propertyId) ?? false));

      // Remover alertas relacionados
      for (final alert in relatedAlerts) {
        await notificationService.deleteAlert(alert.id);
      }
    } catch (e) {
      debugPrint('Erro ao remover alertas do favorito: $e');
    }
  }

  /// Obtém estatísticas de alertas para favoritos
  static Future<Map<String, dynamic>> getFavoriteAlertsStats(String userId) async {
    try {
      final notificationService = NotificationService();
      final userAlerts = await notificationService.getUserAlerts(userId);
      final favorites = await getUserFavorites();

      final favoriteIds = favorites.map((f) => f.id).toSet();
      final favoriteAlerts = userAlerts.where((alert) =>
          alert.propertyId != null && favoriteIds.contains(alert.propertyId));

      return {
        'totalFavorites': favorites.length,
        'favoritesWithAlerts': favoriteAlerts.length,
        'alertsByType': _groupFavoriteAlertsByType(favoriteAlerts),
        'coverage': favorites.isNotEmpty 
            ? (favoriteAlerts.length / favorites.length * 100).round()
            : 0,
      };
    } catch (e) {
      debugPrint('Erro ao obter estatísticas de alertas de favoritos: $e');
      return {};
    }
  }

  /// Mapeia tipo de propriedade para enum do alerta
  static alert_models.AlertPropertyType? _mapPropertyType(PropertyType? propertyType) {
    if (propertyType == null) return null;
    
    switch (propertyType) {
      case PropertyType.apartment:
        return alert_models.AlertPropertyType.apartment;
      case PropertyType.house:
        return alert_models.AlertPropertyType.house;
      case PropertyType.commercial:
        return alert_models.AlertPropertyType.commercial;
      case PropertyType.land:
        return alert_models.AlertPropertyType.land;
    }
  }

  /// Agrupa alertas de favoritos por tipo
  static Map<String, int> _groupFavoriteAlertsByType(
    Iterable<alert_models.PropertyAlert> alerts,
  ) {
    final Map<String, int> grouped = {};
    for (final alert in alerts) {
      final type = alert.type.name;
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }

  /// Sugere alertas baseados nos favoritos do usuário
  static Future<List<Map<String, dynamic>>> suggestAlertsFromFavorites(
    String userId,
  ) async {
    try {
      final favorites = await getUserFavorites();
      final List<Map<String, dynamic>> suggestions = [];

      if (favorites.isEmpty) {
        return suggestions;
      }

      // Agrupar favoritos por características similares
      final groupedByCity = <String, List<Property>>{};
      final groupedByType = <String, List<Property>>{};
      final groupedByPriceRange = <String, List<Property>>{};

      for (final favorite in favorites) {
        // Agrupar por cidade
        groupedByCity[favorite.city] ??= [];
        groupedByCity[favorite.city]!.add(favorite);

        // Agrupar por tipo
        groupedByType[favorite.type.name] ??= [];
        groupedByType[favorite.type.name]!.add(favorite);

        // Agrupar por faixa de preço
        final priceRange = _getPriceRange(favorite.price);
        groupedByPriceRange[priceRange] ??= [];
        groupedByPriceRange[priceRange]!.add(favorite);
      }

      // Criar sugestões baseadas nos grupos
      if (groupedByCity.length > 1) {
        suggestions.add({
          'type': 'city_diversity',
          'title': 'Diversidade de Cidades',
          'description': 'Você tem favoritos em ${groupedByCity.length} cidades diferentes',
          'suggestion': 'Criar alertas específicos para cada cidade',
          'priority': 'medium',
        });
      }

      if (groupedByType.length > 1) {
        suggestions.add({
          'type': 'type_diversity',
          'title': 'Diversidade de Tipos',
          'description': 'Você tem favoritos de ${groupedByType.length} tipos diferentes',
          'suggestion': 'Criar alertas específicos para cada tipo de imóvel',
          'priority': 'medium',
        });
      }

      if (groupedByPriceRange.length > 1) {
        suggestions.add({
          'type': 'price_diversity',
          'title': 'Diversidade de Preços',
          'description': 'Você tem favoritos em ${groupedByPriceRange.length} faixas de preço',
          'suggestion': 'Criar alertas específicos para cada faixa de preço',
          'priority': 'high',
        });
      }

      // Sugestão para alertas de redução de preço
      if (favorites.length >= 3) {
        suggestions.add({
          'type': 'price_drop',
          'title': 'Alertas de Redução de Preço',
          'description': 'Criar alertas para ${favorites.length} imóveis favoritos',
          'suggestion': 'Ser notificado quando o preço de qualquer favorito baixar',
          'priority': 'high',
        });
      }

      return suggestions;
    } catch (e) {
      debugPrint('Erro ao sugerir alertas baseados em favoritos: $e');
      return [];
    }
  }

  /// Obtém faixa de preço para agrupamento
  static String _getPriceRange(double price) {
    if (price < 200000) return 'Até R\$ 200k';
    if (price < 500000) return 'R\$ 200k - R\$ 500k';
    if (price < 1000000) return 'R\$ 500k - R\$ 1M';
    if (price < 2000000) return 'R\$ 1M - R\$ 2M';
    return 'Acima de R\$ 2M';
  }
}
