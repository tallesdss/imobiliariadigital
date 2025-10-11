import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/search_model.dart';
import '../models/property_model.dart';

class VoiceSearchService {
  static final SpeechToText _speechToText = SpeechToText();
  static bool _isInitialized = false;
  static bool _isListening = false;

  /// Inicializa o serviço de reconhecimento de voz
  static Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Verificar permissão de microfone
      final microphonePermission = await Permission.microphone.request();
      if (microphonePermission != PermissionStatus.granted) {
        throw Exception('Permissão de microfone negada');
      }

      // Inicializar SpeechToText
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          if (kDebugMode) {
            debugPrint('Erro no reconhecimento de voz: ${error.errorMsg}');
          }
        },
        onStatus: (status) {
          if (kDebugMode) {
            debugPrint('Status do reconhecimento: $status');
          }
        },
      );

      return _isInitialized;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao inicializar reconhecimento de voz: $e');
      }
      return false;
    }
  }

  /// Verifica se o reconhecimento de voz está disponível
  static Future<bool> isAvailable() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return _speechToText.isAvailable;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao verificar disponibilidade: $e');
      }
      return false;
    }
  }

  /// Inicia o reconhecimento de voz
  static Future<String?> startListening({
    Duration timeout = const Duration(seconds: 30),
    String locale = 'pt_BR',
  }) async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          throw Exception('Falha ao inicializar reconhecimento de voz');
        }
      }

      if (_isListening) {
        await stopListening();
      }

      String? recognizedText;
      bool isCompleted = false;

      _isListening = await _speechToText.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          if (result.finalResult) {
            isCompleted = true;
          }
        },
        listenFor: timeout,
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(partialResults: true),
        localeId: locale,
        onSoundLevelChange: (level) {
          // Callback para mudanças no nível de som
        },
      );

      if (!_isListening) {
        throw Exception('Falha ao iniciar reconhecimento de voz');
      }

      // Aguardar conclusão ou timeout
      final startTime = DateTime.now();
      while (_isListening && !isCompleted) {
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (DateTime.now().difference(startTime) > timeout) {
          await stopListening();
          break;
        }
      }

      return recognizedText;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao iniciar reconhecimento: $e');
      }
      await stopListening();
      return null;
    }
  }

  /// Para o reconhecimento de voz
  static Future<void> stopListening() async {
    try {
      if (_isListening) {
        await _speechToText.stop();
        _isListening = false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao parar reconhecimento: $e');
      }
    }
  }

  /// Cancela o reconhecimento de voz
  static Future<void> cancelListening() async {
    try {
      if (_isListening) {
        await _speechToText.cancel();
        _isListening = false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao cancelar reconhecimento: $e');
      }
    }
  }

  /// Verifica se está ouvindo
  static bool get isListening => _isListening;

  /// Obtém idiomas disponíveis
  static Future<List<LocaleName>> getAvailableLocales() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      final locales = await _speechToText.locales();
      return locales.map((locale) => LocaleName(
        localeId: locale.localeId,
        name: locale.name,
        countryCode: locale.localeId.split('_').length > 1 ? locale.localeId.split('_')[1] : '',
      )).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao obter idiomas: $e');
      }
      return [];
    }
  }

  /// Processa comando de voz e converte para SearchQuery
  static Future<SearchQuery> processVoiceCommand(String voiceText) async {
    try {
      final query = voiceText.toLowerCase();
      SearchQuery searchQuery = const SearchQuery();

      // Análise de tipo de imóvel
      if (query.contains('apartamento') || query.contains('apto')) {
        searchQuery = searchQuery.copyWith(propertyTypes: [PropertyType.apartment]);
      } else if (query.contains('casa')) {
        searchQuery = searchQuery.copyWith(propertyTypes: [PropertyType.house]);
      } else if (query.contains('comercial') || query.contains('loja')) {
        searchQuery = searchQuery.copyWith(propertyTypes: [PropertyType.commercial]);
      } else if (query.contains('terreno') || query.contains('lote')) {
        searchQuery = searchQuery.copyWith(propertyTypes: [PropertyType.land]);
      }

      // Análise de localização
      final cities = _extractCities(query);
      if (cities.isNotEmpty) {
        searchQuery = searchQuery.copyWith(cities: cities);
      }

      // Análise de preço
      final priceRange = _extractPriceRange(query);
      if (priceRange != null) {
        searchQuery = searchQuery.copyWith(
          minPrice: priceRange['min'],
          maxPrice: priceRange['max'],
        );
      }

      // Análise de quartos
      final bedrooms = _extractBedrooms(query);
      if (bedrooms != null) {
        searchQuery = searchQuery.copyWith(
          minBedrooms: bedrooms,
          maxBedrooms: bedrooms,
        );
      }

      // Análise de banheiros
      final bathrooms = _extractBathrooms(query);
      if (bathrooms != null) {
        searchQuery = searchQuery.copyWith(
          minBathrooms: bathrooms,
          maxBathrooms: bathrooms,
        );
      }

      // Análise de características especiais
      if (query.contains('piscina')) {
        // Em uma implementação real, isso seria um filtro de atributos
        searchQuery = searchQuery.copyWith(text: '${searchQuery.text ?? ''} piscina');
      }
      if (query.contains('garagem') || query.contains('vaga')) {
        searchQuery = searchQuery.copyWith(minParkingSpaces: 1);
      }
      if (query.contains('jardim') || query.contains('quintal')) {
        searchQuery = searchQuery.copyWith(text: '${searchQuery.text ?? ''} jardim');
      }

      // Análise de tipo de transação
      if (query.contains('alugar') || query.contains('aluguel')) {
        searchQuery = searchQuery.copyWith(transactionType: PropertyTransactionType.rent);
      } else if (query.contains('comprar') || query.contains('venda')) {
        searchQuery = searchQuery.copyWith(transactionType: PropertyTransactionType.sale);
      }

      // Análise de urgência/prioridade
      if (query.contains('urgente') || query.contains('rápido')) {
        searchQuery = searchQuery.copyWith(sortBy: 'date', sortAscending: false);
      }

      return searchQuery.copyWith(voiceQuery: voiceText);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao processar comando de voz: $e');
      }
      return SearchQuery(voiceQuery: voiceText);
    }
  }

  /// Extrai cidades mencionadas no texto
  static List<String> _extractCities(String query) {
    final cities = <String>[];
    final cityPatterns = {
      'são paulo': 'São Paulo',
      'rio de janeiro': 'Rio de Janeiro',
      'belo horizonte': 'Belo Horizonte',
      'salvador': 'Salvador',
      'brasília': 'Brasília',
      'fortaleza': 'Fortaleza',
      'manaus': 'Manaus',
      'curitiba': 'Curitiba',
      'recife': 'Recife',
      'porto alegre': 'Porto Alegre',
    };

    for (final entry in cityPatterns.entries) {
      if (query.contains(entry.key)) {
        cities.add(entry.value);
      }
    }

    return cities;
  }

  /// Extrai faixa de preço do texto
  static Map<String, double>? _extractPriceRange(String query) {
    // Padrões para extrair preços
    final patterns = [
      RegExp(r'até\s+r?\$?\s*(\d+(?:\.\d{3})*(?:,\d{2})?)', caseSensitive: false),
      RegExp(r'máximo\s+r?\$?\s*(\d+(?:\.\d{3})*(?:,\d{2})?)', caseSensitive: false),
      RegExp(r'até\s+(\d+)\s*mil', caseSensitive: false),
      RegExp(r'até\s+(\d+)\s*k', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(query);
      if (match != null) {
        final priceStr = match.group(1)!.replaceAll('.', '').replaceAll(',', '.');
        double? price = double.tryParse(priceStr);
        
        if (price != null) {
          // Se mencionou "mil" ou "k", multiplicar por 1000
          if (query.contains('mil') || query.contains('k')) {
            price *= 1000;
          }
          return {'min': 0, 'max': price};
        }
      }
    }

    // Padrão para faixa de preço
    final rangePattern = RegExp(
      r'entre\s+r?\$?\s*(\d+(?:\.\d{3})*(?:,\d{2})?)\s*e\s+r?\$?\s*(\d+(?:\.\d{3})*(?:,\d{2})?)',
      caseSensitive: false,
    );
    
    final rangeMatch = rangePattern.firstMatch(query);
    if (rangeMatch != null) {
      final minStr = rangeMatch.group(1)!.replaceAll('.', '').replaceAll(',', '.');
      final maxStr = rangeMatch.group(2)!.replaceAll('.', '').replaceAll(',', '.');
      
      final minPrice = double.tryParse(minStr);
      final maxPrice = double.tryParse(maxStr);
      
      if (minPrice != null && maxPrice != null) {
        return {'min': minPrice, 'max': maxPrice};
      }
    }

    return null;
  }

  /// Extrai número de quartos do texto
  static int? _extractBedrooms(String query) {
    final patterns = [
      RegExp(r'(\d+)\s*quarto', caseSensitive: false),
      RegExp(r'(\d+)\s*dormitório', caseSensitive: false),
      RegExp(r'(\d+)\s*suite', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(query);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }

    // Padrões especiais
    if (query.contains('um quarto') || query.contains('1 quarto')) return 1;
    if (query.contains('dois quartos') || query.contains('2 quartos')) return 2;
    if (query.contains('três quartos') || query.contains('3 quartos')) return 3;
    if (query.contains('quatro quartos') || query.contains('4 quartos')) return 4;

    return null;
  }

  /// Extrai número de banheiros do texto
  static int? _extractBathrooms(String query) {
    final patterns = [
      RegExp(r'(\d+)\s*banheiro', caseSensitive: false),
      RegExp(r'(\d+)\s*wc', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(query);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }

    // Padrões especiais
    if (query.contains('um banheiro') || query.contains('1 banheiro')) return 1;
    if (query.contains('dois banheiros') || query.contains('2 banheiros')) return 2;
    if (query.contains('três banheiros') || query.contains('3 banheiros')) return 3;

    return null;
  }

  /// Obtém sugestões de comandos de voz
  static List<String> getVoiceCommandSuggestions() {
    return [
      'Apartamento 2 quartos em São Paulo',
      'Casa com piscina até 500 mil',
      'Imóvel para alugar com garagem',
      'Terreno em Belo Horizonte',
      'Apartamento 3 quartos com 2 banheiros',
      'Casa com jardim até 300 mil',
      'Imóvel comercial no centro',
      'Apartamento próximo ao metrô',
    ];
  }

  /// Valida se o texto reconhecido é válido para busca
  static bool isValidSearchCommand(String text) {
    if (text.isEmpty || text.length < 3) return false;
    
    // Verificar se contém palavras-chave relevantes
    final keywords = [
      'apartamento', 'casa', 'terreno', 'comercial',
      'quarto', 'banheiro', 'garagem', 'piscina',
      'alugar', 'comprar', 'venda', 'aluguel',
      'são paulo', 'rio de janeiro', 'belo horizonte',
      'mil', 'milhão', 'reais', 'preço',
    ];
    
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword));
  }

  /// Obtém feedback do reconhecimento
  static String getRecognitionFeedback(String? text) {
    if (text == null || text.isEmpty) {
      return 'Não foi possível reconhecer o áudio. Tente falar mais claramente.';
    }
    
    if (!isValidSearchCommand(text)) {
      return 'Comando não reconhecido. Tente usar palavras como "apartamento", "casa", "quarto", etc.';
    }
    
    return 'Comando reconhecido: "$text"';
  }
}

/// Classe para informações de idioma
class LocaleName {
  final String localeId;
  final String name;
  final String countryCode;

  const LocaleName({
    required this.localeId,
    required this.name,
    required this.countryCode,
  });
}
