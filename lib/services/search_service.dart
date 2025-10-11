import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_model.dart';
import '../models/search_model.dart';
import 'property_service.dart';
import 'supabase_service.dart';
import '../config/supabase_config.dart';

class SearchService {
  static const String _searchHistoryKey = 'search_history';
  static const String _searchSuggestionsKey = 'search_suggestions';
  static const int _maxHistoryItems = 50;
  static const int _maxSuggestions = 20;

  /// Busca avançada de imóveis
  static Future<List<Property>> searchProperties(SearchQuery query) async {
    try {
      // Obter todos os imóveis ativos
      final allProperties = await PropertyService.getAllProperties();
      
      // Aplicar filtros de busca
      var filteredProperties = _applySearchFilters(allProperties, query);
      
      // Aplicar busca por texto se especificada
      if (query.text != null && query.text!.isNotEmpty) {
        filteredProperties = _applyTextSearch(filteredProperties, query.text!);
      }
      
      // Aplicar busca por localização se especificada
      if (query.latitude != null && query.longitude != null && query.radiusKm != null) {
        filteredProperties = _applyLocationSearch(filteredProperties, query);
      }
      
      // Aplicar busca por imagem se especificada
      if (query.imageUrl != null && query.imageUrl!.isNotEmpty) {
        filteredProperties = await _applyImageSearch(filteredProperties, query.imageUrl!);
      }
      
      // Aplicar ordenação
      filteredProperties = _applySorting(filteredProperties, query);
      
      // Salvar no histórico se houver resultados
      if (filteredProperties.isNotEmpty) {
        await _saveToHistory(query, filteredProperties.length);
      }
      
      return filteredProperties;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro na busca: $e');
      }
      throw Exception('Erro na busca. Tente novamente.');
    }
  }

  /// Aplica filtros básicos de busca
  static List<Property> _applySearchFilters(List<Property> properties, SearchQuery query) {
    return properties.where((property) {
      // Filtro de tipo de imóvel
      if (query.propertyTypes != null && 
          query.propertyTypes!.isNotEmpty && 
          !query.propertyTypes!.contains(property.type)) {
        return false;
      }

      // Filtro de cidade
      if (query.cities != null && 
          query.cities!.isNotEmpty && 
          !query.cities!.contains(property.city)) {
        return false;
      }

      // Filtro de bairro
      if (query.neighborhoods != null && query.neighborhoods!.isNotEmpty) {
        final hasMatchingNeighborhood = query.neighborhoods!.any(
          (neighborhood) => property.address.toLowerCase().contains(neighborhood.toLowerCase())
        );
        if (!hasMatchingNeighborhood) {
          return false;
        }
      }

      // Filtro de preço
      if (query.minPrice != null && property.price < query.minPrice!) {
        return false;
      }
      if (query.maxPrice != null && property.price > query.maxPrice!) {
        return false;
      }

      // Filtro de tipo de transação
      if (query.transactionType != null && 
          property.transactionType != query.transactionType) {
        return false;
      }

      // Filtros de características
      final attributes = property.attributes;
      
      // Quartos
      if (query.minBedrooms != null) {
        final bedrooms = attributes['bedrooms'] as int? ?? 0;
        if (bedrooms < query.minBedrooms!) {
          return false;
        }
      }
      if (query.maxBedrooms != null) {
        final bedrooms = attributes['bedrooms'] as int? ?? 0;
        if (bedrooms > query.maxBedrooms!) {
          return false;
        }
      }

      // Banheiros
      if (query.minBathrooms != null) {
        final bathrooms = attributes['bathrooms'] as int? ?? 0;
        if (bathrooms < query.minBathrooms!) {
          return false;
        }
      }
      if (query.maxBathrooms != null) {
        final bathrooms = attributes['bathrooms'] as int? ?? 0;
        if (bathrooms > query.maxBathrooms!) {
          return false;
        }
      }

      // Vagas de garagem
      if (query.minParkingSpaces != null) {
        final parking = attributes['parking_spaces'] as int? ?? 0;
        if (parking < query.minParkingSpaces!) {
          return false;
        }
      }
      if (query.maxParkingSpaces != null) {
        final parking = attributes['parking_spaces'] as int? ?? 0;
        if (parking > query.maxParkingSpaces!) {
          return false;
        }
      }

      // Área
      if (query.minArea != null) {
        final area = attributes['area'] as double? ?? 0.0;
        if (area < query.minArea!) {
          return false;
        }
      }
      if (query.maxArea != null) {
        final area = attributes['area'] as double? ?? 0.0;
        if (area > query.maxArea!) {
          return false;
        }
      }

      // Condomínio e IPTU
      if (query.maxCondominium != null) {
        final condominium = attributes['condominium'] as double? ?? 0.0;
        if (condominium > query.maxCondominium!) {
          return false;
        }
      }
      if (query.maxIptu != null) {
        final iptu = attributes['iptu'] as double? ?? 0.0;
        if (iptu > query.maxIptu!) {
          return false;
        }
      }

      // Filtros especiais
      if (query.acceptProposal == true) {
        final acceptsProposal = attributes['accepts_proposal'] as bool? ?? false;
        if (!acceptsProposal) {
          return false;
        }
      }

      if (query.hasFinancing == true) {
        final hasFinancing = attributes['has_financing'] as bool? ?? false;
        if (!hasFinancing) {
          return false;
        }
      }

      if (query.isFeatured == true && !property.isFeatured) {
        return false;
      }

      if (query.isLaunch == true && !property.isLaunch) {
        return false;
      }

      // Filtros de data
      if (query.startDate != null && property.createdAt.isBefore(query.startDate!)) {
        return false;
      }
      if (query.endDate != null && property.createdAt.isAfter(query.endDate!)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Aplica busca por texto
  static List<Property> _applyTextSearch(List<Property> properties, String searchText) {
    final searchTerms = searchText.toLowerCase().split(' ').where((term) => term.isNotEmpty).toList();
    
    return properties.where((property) {
      final searchableText = '${property.title} ${property.description} ${property.address} ${property.city} ${property.state}'.toLowerCase();
      
      // Verificar se todos os termos de busca estão presentes
      return searchTerms.every((term) => searchableText.contains(term));
    }).toList();
  }

  /// Aplica busca por localização
  static List<Property> _applyLocationSearch(List<Property> properties, SearchQuery query) {
    if (query.latitude == null || query.longitude == null || query.radiusKm == null) {
      return properties;
    }

    final searchLocation = LocationData(
      latitude: query.latitude!,
      longitude: query.longitude!,
      address: '',
      city: '',
      state: '',
      zipCode: '',
    );

    return properties.where((property) {
      // Simular coordenadas do imóvel (em uma implementação real, isso viria do banco)
      final propertyLocation = _getPropertyLocation(property);
      final distance = searchLocation.distanceTo(propertyLocation);
      
      return distance <= query.radiusKm!;
    }).toList();
  }

  /// Simula localização do imóvel (em implementação real, viria do banco)
  static LocationData _getPropertyLocation(Property property) {
    // Simular coordenadas baseadas na cidade
    final cityCoordinates = _getCityCoordinates(property.city);
    return LocationData(
      latitude: cityCoordinates['lat']! + (Random().nextDouble() - 0.5) * 0.1,
      longitude: cityCoordinates['lng']! + (Random().nextDouble() - 0.5) * 0.1,
      address: property.address,
      city: property.city,
      state: property.state,
      zipCode: property.zipCode,
    );
  }

  /// Coordenadas aproximadas de algumas cidades brasileiras
  static Map<String, double> _getCityCoordinates(String city) {
    final coordinates = {
      'São Paulo': {'lat': -23.5505, 'lng': -46.6333},
      'Rio de Janeiro': {'lat': -22.9068, 'lng': -43.1729},
      'Belo Horizonte': {'lat': -19.9167, 'lng': -43.9345},
      'Salvador': {'lat': -12.9714, 'lng': -38.5014},
      'Brasília': {'lat': -15.7801, 'lng': -47.9292},
      'Fortaleza': {'lat': -3.7172, 'lng': -38.5434},
      'Manaus': {'lat': -3.1190, 'lng': -60.0217},
      'Curitiba': {'lat': -25.4244, 'lng': -49.2654},
      'Recife': {'lat': -8.0476, 'lng': -34.8770},
      'Porto Alegre': {'lat': -30.0346, 'lng': -51.2177},
    };
    
    return coordinates[city] ?? {'lat': -23.5505, 'lng': -46.6333}; // Default para São Paulo
  }

  /// Aplica busca por imagem (simulada)
  static Future<List<Property>> _applyImageSearch(List<Property> properties, String imageUrl) async {
    // Em uma implementação real, aqui seria feita a análise da imagem
    // e comparação com as imagens dos imóveis usando IA/ML
    
    // Por enquanto, retorna propriedades com características similares
    return properties.where((property) {
      // Simular busca por características visuais
      final attributes = property.attributes;
      final hasPool = attributes['has_pool'] as bool? ?? false;
      final hasGarden = attributes['has_garden'] as bool? ?? false;
      final hasBalcony = attributes['has_balcony'] as bool? ?? false;
      
      // Retorna propriedades com características especiais
      return hasPool || hasGarden || hasBalcony;
    }).toList();
  }

  /// Aplica ordenação aos resultados
  static List<Property> _applySorting(List<Property> properties, SearchQuery query) {
    final sortedProperties = List<Property>.from(properties);
    
    sortedProperties.sort((a, b) {
      int comparison = 0;
      
      switch (query.sortBy) {
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'area':
          final aArea = a.attributes['area'] as double? ?? 0.0;
          final bArea = b.attributes['area'] as double? ?? 0.0;
          comparison = aArea.compareTo(bArea);
          break;
        case 'bedrooms':
          final aBedrooms = a.attributes['bedrooms'] as int? ?? 0;
          final bBedrooms = b.attributes['bedrooms'] as int? ?? 0;
          comparison = aBedrooms.compareTo(bBedrooms);
          break;
        case 'relevance':
          // Ordenar por relevância (imóveis em destaque primeiro)
          if (a.isFeatured && !b.isFeatured) return -1;
          if (!a.isFeatured && b.isFeatured) return 1;
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }
      
      return query.sortAscending == true ? comparison : -comparison;
    });
    
    return sortedProperties;
  }

  /// Salva busca no histórico
  static Future<void> _saveToHistory(SearchQuery query, int resultCount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_searchHistoryKey) ?? [];
      
      final newHistory = SearchHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        query: query.text ?? query.voiceQuery ?? 'Busca avançada',
        searchQuery: query,
        timestamp: DateTime.now(),
        resultCount: resultCount,
      );
      
      historyJson.insert(0, jsonEncode(newHistory.toJson()));
      
      // Manter apenas os últimos N itens
      if (historyJson.length > _maxHistoryItems) {
        historyJson.removeRange(_maxHistoryItems, historyJson.length);
      }
      
      await prefs.setStringList(_searchHistoryKey, historyJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar histórico: $e');
      }
    }
  }

  /// Obtém histórico de buscas
  static Future<List<SearchHistory>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_searchHistoryKey) ?? [];
      
      return historyJson
          .map((json) => SearchHistory.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar histórico: $e');
      }
      return [];
    }
  }

  /// Limpa histórico de buscas
  static Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchHistoryKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao limpar histórico: $e');
      }
    }
  }

  /// Obtém sugestões de busca
  static Future<List<SearchSuggestion>> getSearchSuggestions(String query) async {
    try {
      if (query.isEmpty) {
        return await _getPopularSuggestions();
      }
      
      final allSuggestions = await _getAllSuggestions();
      final filteredSuggestions = allSuggestions
          .where((suggestion) => 
              suggestion.text.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      // Ordenar por frequência e data de uso
      filteredSuggestions.sort((a, b) {
        final frequencyComparison = b.frequency.compareTo(a.frequency);
        if (frequencyComparison != 0) return frequencyComparison;
        return b.lastUsed.compareTo(a.lastUsed);
      });
      
      return filteredSuggestions.take(_maxSuggestions).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao obter sugestões: $e');
      }
      return [];
    }
  }

  /// Obtém sugestões populares
  static Future<List<SearchSuggestion>> _getPopularSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final suggestionsJson = prefs.getStringList(_searchSuggestionsKey) ?? [];
      
      if (suggestionsJson.isEmpty) {
        // Sugestões padrão
        return _getDefaultSuggestions();
      }
      
      final suggestions = suggestionsJson
          .map((json) => SearchSuggestion.fromJson(jsonDecode(json)))
          .toList();
      
      // Ordenar por frequência
      suggestions.sort((a, b) => b.frequency.compareTo(a.frequency));
      
      return suggestions.take(_maxSuggestions).toList();
    } catch (e) {
      return _getDefaultSuggestions();
    }
  }

  /// Obtém todas as sugestões
  static Future<List<SearchSuggestion>> _getAllSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final suggestionsJson = prefs.getStringList(_searchSuggestionsKey) ?? [];
      
      return suggestionsJson
          .map((json) => SearchSuggestion.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Sugestões padrão
  static List<SearchSuggestion> _getDefaultSuggestions() {
    return [
      SearchSuggestion(
        text: 'Apartamento 2 quartos',
        type: 'text',
        frequency: 100,
        lastUsed: DateTime.now(),
      ),
      SearchSuggestion(
        text: 'Casa com piscina',
        type: 'text',
        frequency: 80,
        lastUsed: DateTime.now(),
      ),
      SearchSuggestion(
        text: 'São Paulo',
        type: 'location',
        frequency: 90,
        lastUsed: DateTime.now(),
      ),
      SearchSuggestion(
        text: 'Rio de Janeiro',
        type: 'location',
        frequency: 85,
        lastUsed: DateTime.now(),
      ),
      SearchSuggestion(
        text: 'Até R\$ 300.000',
        type: 'text',
        frequency: 75,
        lastUsed: DateTime.now(),
      ),
      SearchSuggestion(
        text: 'Com garagem',
        type: 'text',
        frequency: 70,
        lastUsed: DateTime.now(),
      ),
    ];
  }

  /// Atualiza sugestões com nova busca
  static Future<void> updateSuggestions(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final suggestionsJson = prefs.getStringList(_searchSuggestionsKey) ?? [];
      
      final suggestions = suggestionsJson
          .map((json) => SearchSuggestion.fromJson(jsonDecode(json)))
          .toList();
      
      // Procurar sugestão existente
      final existingIndex = suggestions.indexWhere((s) => s.text == query);
      
      if (existingIndex != -1) {
        // Atualizar frequência e data
        suggestions[existingIndex] = suggestions[existingIndex].copyWith(
          frequency: suggestions[existingIndex].frequency + 1,
          lastUsed: DateTime.now(),
        );
      } else {
        // Adicionar nova sugestão
        suggestions.add(SearchSuggestion(
          text: query,
          type: 'text',
          frequency: 1,
          lastUsed: DateTime.now(),
        ));
      }
      
      // Manter apenas as sugestões mais relevantes
      suggestions.sort((a, b) => b.frequency.compareTo(a.frequency));
      final limitedSuggestions = suggestions.take(_maxSuggestions * 2).toList();
      
      final updatedJson = limitedSuggestions
          .map((suggestion) => jsonEncode(suggestion.toJson()))
          .toList();
      
      await prefs.setStringList(_searchSuggestionsKey, updatedJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao atualizar sugestões: $e');
      }
    }
  }

  /// Busca por voz (simulada)
  static Future<SearchQuery> processVoiceQuery(String voiceQuery) async {
    // Em uma implementação real, aqui seria feita a conversão de voz para texto
    // e análise do comando para extrair parâmetros de busca
    
    final query = voiceQuery.toLowerCase();
    SearchQuery searchQuery = const SearchQuery();
    
    // Análise simples de comandos de voz
    if (query.contains('apartamento')) {
      searchQuery = searchQuery.copyWith(propertyTypes: [PropertyType.apartment]);
    } else if (query.contains('casa')) {
      searchQuery = searchQuery.copyWith(propertyTypes: [PropertyType.house]);
    }
    
    if (query.contains('são paulo')) {
      searchQuery = searchQuery.copyWith(cities: ['São Paulo']);
    } else if (query.contains('rio de janeiro')) {
      searchQuery = searchQuery.copyWith(cities: ['Rio de Janeiro']);
    }
    
    // Extrair preço se mencionado
    final priceRegex = RegExp(r'até\s+r?\$?\s*(\d+(?:\.\d{3})*(?:,\d{2})?)', caseSensitive: false);
    final priceMatch = priceRegex.firstMatch(query);
    if (priceMatch != null) {
      final priceStr = priceMatch.group(1)!.replaceAll('.', '').replaceAll(',', '.');
      final price = double.tryParse(priceStr);
      if (price != null) {
        searchQuery = searchQuery.copyWith(maxPrice: price);
      }
    }
    
    // Extrair número de quartos
    final bedroomRegex = RegExp(r'(\d+)\s*quarto', caseSensitive: false);
    final bedroomMatch = bedroomRegex.firstMatch(query);
    if (bedroomMatch != null) {
      final bedrooms = int.tryParse(bedroomMatch.group(1)!);
      if (bedrooms != null) {
        searchQuery = searchQuery.copyWith(minBedrooms: bedrooms, maxBedrooms: bedrooms);
      }
    }
    
    return searchQuery.copyWith(voiceQuery: voiceQuery);
  }

  /// Busca por imagem (simulada)
  static Future<List<ImageSearchResult>> searchByImage(String imageUrl) async {
    // Em uma implementação real, aqui seria feita a análise da imagem
    // usando serviços de IA como Google Vision API, AWS Rekognition, etc.
    
    try {
      final allProperties = await PropertyService.getAllProperties();
      final results = <ImageSearchResult>[];
      
      for (final property in allProperties) {
        // Simular análise de similaridade
        final similarity = Random().nextDouble();
        if (similarity > 0.3) { // Apenas resultados com similaridade > 30%
          results.add(ImageSearchResult(
            property: property,
            similarity: similarity,
            matchingFeatures: _getMatchingFeatures(property),
          ));
        }
      }
      
      // Ordenar por similaridade
      results.sort((a, b) => b.similarity.compareTo(a.similarity));
      
      return results.take(20).toList(); // Retornar apenas os 20 melhores
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro na busca por imagem: $e');
      }
      return [];
    }
  }

  /// Obtém características que fazem match (simulado)
  static List<String> _getMatchingFeatures(Property property) {
    final features = <String>[];
    final attributes = property.attributes;
    
    if (attributes['has_pool'] as bool? ?? false) {
      features.add('Piscina');
    }
    if (attributes['has_garden'] as bool? ?? false) {
      features.add('Jardim');
    }
    if (attributes['has_balcony'] as bool? ?? false) {
      features.add('Varanda');
    }
    if (attributes['has_garage'] as bool? ?? false) {
      features.add('Garagem');
    }
    
    return features;
  }

  /// Obtém cidades disponíveis para busca
  static Future<List<String>> getAvailableCities() async {
    try {
      return await PropertyService.getCities();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao obter cidades: $e');
      }
      return [];
    }
  }

  /// Obtém bairros disponíveis para uma cidade
  static Future<List<String>> getAvailableNeighborhoods(String city) async {
    try {
      final properties = await PropertyService.getAllProperties();
      final neighborhoods = properties
          .where((p) => p.city == city)
          .map((p) => _extractNeighborhood(p.address))
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      
      return neighborhoods;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao obter bairros: $e');
      }
      return [];
    }
  }

  /// Extrai bairro do endereço (simulado)
  static String _extractNeighborhood(String address) {
    // Em uma implementação real, isso seria mais sofisticado
    final parts = address.split(',');
    if (parts.length > 1) {
      return parts[1].trim();
    }
    return '';
  }
}
