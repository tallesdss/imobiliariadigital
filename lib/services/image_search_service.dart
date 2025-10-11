import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/property_model.dart';
import '../models/search_model.dart';

class ImageSearchService {
  static const String _mockApiEndpoint = 'https://api.example.com/image-search';
  static const int _maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> _supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];

  /// Seleciona imagem da galeria
  static Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        
        // Validar tamanho do arquivo
        if (await file.length() > _maxImageSize) {
          throw Exception('Imagem muito grande. Máximo permitido: 5MB');
        }
        
        return file;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao selecionar imagem: $e');
      }
      throw Exception('Erro ao selecionar imagem: ${e.toString()}');
    }
  }

  /// Captura imagem da câmera
  static Future<File?> captureImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        
        // Validar tamanho do arquivo
        if (await file.length() > _maxImageSize) {
          throw Exception('Imagem muito grande. Máximo permitido: 5MB');
        }
        
        return file;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao capturar imagem: $e');
      }
      throw Exception('Erro ao capturar imagem: ${e.toString()}');
    }
  }

  /// Processa busca por imagem
  static Future<List<ImageSearchResult>> searchByImage(File imageFile) async {
    try {
      // Validar arquivo
      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não encontrado');
      }

      final fileSize = await imageFile.length();
      if (fileSize > _maxImageSize) {
        throw Exception('Imagem muito grande. Máximo permitido: 5MB');
      }

      // Em uma implementação real, aqui seria feita a análise da imagem
      // usando serviços como Google Vision API, AWS Rekognition, etc.
      
      // Por enquanto, simulamos a análise
      final analysisResult = await _analyzeImageMock(imageFile);
      
      // Buscar propriedades similares
      final similarProperties = await _findSimilarProperties(analysisResult);
      
      return similarProperties;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro na busca por imagem: $e');
      }
      throw Exception('Erro na busca por imagem: ${e.toString()}');
    }
  }

  /// Análise mockada da imagem
  static Future<ImageAnalysisResult> _analyzeImageMock(File imageFile) async {
    // Simular delay de processamento
    await Future.delayed(const Duration(seconds: 2));
    
    // Em uma implementação real, aqui seria feita a análise real da imagem
    // Por enquanto, retornamos dados simulados
    return ImageAnalysisResult(
      detectedObjects: [
        'casa', 'jardim', 'piscina', 'garagem', 'varanda'
      ],
      architecturalStyle: 'moderno',
      propertyType: PropertyType.house,
      estimatedBedrooms: 3,
      estimatedBathrooms: 2,
      hasPool: true,
      hasGarden: true,
      hasGarage: true,
      hasBalcony: true,
      colorScheme: ['branco', 'cinza', 'verde'],
      confidence: 0.85,
    );
  }

  /// Busca propriedades similares baseadas na análise
  static Future<List<ImageSearchResult>> _findSimilarProperties(
    ImageAnalysisResult analysis,
  ) async {
    try {
      // Em uma implementação real, isso seria uma consulta otimizada no banco
      // Por enquanto, simulamos com dados mockados
      
      final similarProperties = <ImageSearchResult>[];
      
      // Simular busca de propriedades similares
      for (int i = 0; i < 15; i++) {
        final similarity = _calculateSimilarity(analysis, i);
        
        if (similarity > 0.3) { // Apenas resultados com similaridade > 30%
          final property = _createMockProperty(i);
          final matchingFeatures = _getMatchingFeatures(analysis, property);
          
          similarProperties.add(ImageSearchResult(
            property: property,
            similarity: similarity,
            matchingFeatures: matchingFeatures,
          ));
        }
      }
      
      // Ordenar por similaridade
      similarProperties.sort((a, b) => b.similarity.compareTo(a.similarity));
      
      return similarProperties.take(10).toList(); // Retornar apenas os 10 melhores
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao buscar propriedades similares: $e');
      }
      return [];
    }
  }

  /// Calcula similaridade entre análise e propriedade (simulado)
  static double _calculateSimilarity(ImageAnalysisResult analysis, int propertyIndex) {
    // Simular cálculo de similaridade baseado em características
    final baseSimilarity = 0.3 + (propertyIndex % 7) * 0.1;
    
    // Ajustar baseado no tipo de propriedade
    if (analysis.propertyType == PropertyType.house && propertyIndex % 3 == 0) {
      return baseSimilarity + 0.2;
    }
    
    // Ajustar baseado em características
    if (analysis.hasPool && propertyIndex % 4 == 0) {
      return baseSimilarity + 0.15;
    }
    
    if (analysis.hasGarden && propertyIndex % 5 == 0) {
      return baseSimilarity + 0.1;
    }
    
    return baseSimilarity;
  }

  /// Cria propriedade mockada
  static Property _createMockProperty(int index) {
    return Property(
      id: 'img_search_$index',
      title: 'Imóvel Similar ${index + 1}',
      description: 'Propriedade com características similares à imagem enviada',
      price: 250000 + (index * 75000),
      type: index % 2 == 0 ? PropertyType.house : PropertyType.apartment,
      status: PropertyStatus.active,
      transactionType: PropertyTransactionType.sale,
      address: 'Rua Similar ${index + 1}, ${index + 100}',
      city: 'São Paulo',
      state: 'SP',
      zipCode: '01234-${index.toString().padLeft(3, '0')}',
      photos: ['https://example.com/property_$index.jpg'],
      videos: [],
      attributes: {
        'bedrooms': 2 + (index % 3),
        'bathrooms': 1 + (index % 2),
        'area': 60.0 + (index * 15),
        'parking_spaces': index % 2,
        'has_pool': index % 4 == 0,
        'has_garden': index % 3 == 0,
        'has_garage': index % 2 == 0,
        'has_balcony': index % 3 == 1,
      },
      realtorId: 'realtor_${index % 5}',
      realtorName: 'Corretor ${index % 5 + 1}',
      realtorPhone: '(11) 99999-${index.toString().padLeft(4, '0')}',
      adminContact: 'admin@imobiliaria.com',
      createdAt: DateTime.now().subtract(Duration(days: index)),
      updatedAt: DateTime.now().subtract(Duration(days: index)),
    );
  }

  /// Obtém características que fazem match
  static List<String> _getMatchingFeatures(ImageAnalysisResult analysis, Property property) {
    final features = <String>[];
    final attributes = property.attributes;
    
    if (analysis.hasPool && (attributes['has_pool'] as bool? ?? false)) {
      features.add('Piscina');
    }
    if (analysis.hasGarden && (attributes['has_garden'] as bool? ?? false)) {
      features.add('Jardim');
    }
    if (analysis.hasGarage && (attributes['has_garage'] as bool? ?? false)) {
      features.add('Garagem');
    }
    if (analysis.hasBalcony && (attributes['has_balcony'] as bool? ?? false)) {
      features.add('Varanda');
    }
    
    // Adicionar características baseadas no tipo
    if (analysis.propertyType == property.type) {
      features.add('Tipo similar');
    }
    
    // Adicionar características baseadas no número de quartos
    final propertyBedrooms = attributes['bedrooms'] as int? ?? 0;
    if ((analysis.estimatedBedrooms - propertyBedrooms).abs() <= 1) {
      features.add('Número de quartos similar');
    }
    
    return features;
  }

  /// Valida formato da imagem
  static bool isValidImageFormat(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return _supportedFormats.contains(extension);
  }

  /// Obtém informações da imagem
  static Future<ImageInfo> getImageInfo(File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      final fileName = imageFile.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      
      return ImageInfo(
        fileName: fileName,
        fileSize: fileSize,
        format: extension,
        isValidFormat: isValidImageFormat(fileName),
        isValidSize: fileSize <= _maxImageSize,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao obter informações da imagem: $e');
      }
      throw Exception('Erro ao obter informações da imagem');
    }
  }

  /// Obtém sugestões de busca por imagem
  static List<String> getImageSearchSuggestions() {
    return [
      'Fotografe a fachada do imóvel',
      'Capture a sala de estar',
      'Fotografe a cozinha',
      'Capture o quarto principal',
      'Fotografe o jardim ou quintal',
      'Capture a piscina ou área de lazer',
      'Fotografe a garagem',
      'Capture a vista da janela',
    ];
  }

  /// Processa múltiplas imagens
  static Future<List<ImageSearchResult>> searchByMultipleImages(List<File> imageFiles) async {
    try {
      if (imageFiles.isEmpty) {
        throw Exception('Nenhuma imagem fornecida');
      }

      if (imageFiles.length > 5) {
        throw Exception('Máximo de 5 imagens permitidas');
      }

      final allResults = <ImageSearchResult>[];
      
      for (final imageFile in imageFiles) {
        final results = await searchByImage(imageFile);
        allResults.addAll(results);
      }
      
      // Remover duplicatas e ordenar por similaridade
      final uniqueResults = <String, ImageSearchResult>{};
      for (final result in allResults) {
        final key = result.property.id;
        if (!uniqueResults.containsKey(key) || 
            uniqueResults[key]!.similarity < result.similarity) {
          uniqueResults[key] = result;
        }
      }
      
      final finalResults = uniqueResults.values.toList();
      finalResults.sort((a, b) => b.similarity.compareTo(a.similarity));
      
      return finalResults.take(15).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro na busca por múltiplas imagens: $e');
      }
      throw Exception('Erro na busca por múltiplas imagens: ${e.toString()}');
    }
  }
}

/// Classe para resultado da análise de imagem
class ImageAnalysisResult {
  final List<String> detectedObjects;
  final String architecturalStyle;
  final PropertyType propertyType;
  final int estimatedBedrooms;
  final int estimatedBathrooms;
  final bool hasPool;
  final bool hasGarden;
  final bool hasGarage;
  final bool hasBalcony;
  final List<String> colorScheme;
  final double confidence;

  const ImageAnalysisResult({
    required this.detectedObjects,
    required this.architecturalStyle,
    required this.propertyType,
    required this.estimatedBedrooms,
    required this.estimatedBathrooms,
    required this.hasPool,
    required this.hasGarden,
    required this.hasGarage,
    required this.hasBalcony,
    required this.colorScheme,
    required this.confidence,
  });
}

/// Classe para informações da imagem
class ImageInfo {
  final String fileName;
  final int fileSize;
  final String format;
  final bool isValidFormat;
  final bool isValidSize;

  const ImageInfo({
    required this.fileName,
    required this.fileSize,
    required this.format,
    required this.isValidFormat,
    required this.isValidSize,
  });

  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
