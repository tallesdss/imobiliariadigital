import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'supabase_service.dart';

class UploadService {
  static const Uuid _uuid = Uuid();
  static const String _bucketName = 'property-media';
  static const int _maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int _maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const List<String> _allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> _allowedVideoTypes = ['mp4', 'mov', 'avi', 'webm'];

  /// Seleciona e faz upload de uma foto
  static Future<String?> pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await uploadImageFile(File(image.path));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao selecionar imagem: $e');
      }
      throw Exception('Erro ao selecionar imagem. Tente novamente.');
    }
  }

  /// Seleciona e faz upload de múltiplas fotos
  static Future<List<String>> pickAndUploadMultipleImages({int maxImages = 10}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isEmpty) return [];

      final List<String> uploadedUrls = [];
      
      for (final image in images.take(maxImages)) {
        try {
          final url = await uploadImageFile(File(image.path));
          if (url != null) {
            uploadedUrls.add(url);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Erro ao fazer upload da imagem ${image.path}: $e');
          }
          // Continua com as outras imagens mesmo se uma falhar
        }
      }

      return uploadedUrls;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao selecionar múltiplas imagens: $e');
      }
      throw Exception('Erro ao selecionar imagens. Tente novamente.');
    }
  }

  /// Seleciona e faz upload de um vídeo
  static Future<String?> pickAndUploadVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video == null) return null;

      return await uploadVideoFile(File(video.path));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao selecionar vídeo: $e');
      }
      throw Exception('Erro ao selecionar vídeo. Tente novamente.');
    }
  }

  /// Seleciona e faz upload de um arquivo de vídeo usando file_picker
  static Future<String?> pickAndUploadVideoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return await uploadVideoFile(File(result.files.single.path!));
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao selecionar arquivo de vídeo: $e');
      }
      throw Exception('Erro ao selecionar arquivo de vídeo. Tente novamente.');
    }
  }

  /// Faz upload de um arquivo de imagem
  static Future<String?> uploadImageFile(File imageFile) async {
    try {
      // Validar tamanho do arquivo
      final fileSize = await imageFile.length();
      if (fileSize > _maxImageSize) {
        throw Exception('Imagem muito grande. Tamanho máximo: 5MB');
      }

      // Validar tipo do arquivo
      final extension = path.extension(imageFile.path).toLowerCase().substring(1);
      if (!_allowedImageTypes.contains(extension)) {
        throw Exception('Tipo de arquivo não suportado. Use: ${_allowedImageTypes.join(', ')}');
      }

      // Gerar nome único para o arquivo
      final fileName = '${_uuid.v4()}.$extension';
      final filePath = 'images/$fileName';

      // Fazer upload para o Supabase Storage
      final bytes = await imageFile.readAsBytes();
      await SupabaseService.client.storage
          .from(_bucketName)
          .uploadBinary(filePath, bytes);

      // Obter URL pública
      final publicUrl = SupabaseService.client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao fazer upload da imagem: $e');
      }
      throw Exception('Erro ao fazer upload da imagem. Tente novamente.');
    }
  }

  /// Faz upload de um arquivo de vídeo
  static Future<String?> uploadVideoFile(File videoFile) async {
    try {
      // Validar tamanho do arquivo
      final fileSize = await videoFile.length();
      if (fileSize > _maxVideoSize) {
        throw Exception('Vídeo muito grande. Tamanho máximo: 50MB');
      }

      // Validar tipo do arquivo
      final extension = path.extension(videoFile.path).toLowerCase().substring(1);
      if (!_allowedVideoTypes.contains(extension)) {
        throw Exception('Tipo de arquivo não suportado. Use: ${_allowedVideoTypes.join(', ')}');
      }

      // Gerar nome único para o arquivo
      final fileName = '${_uuid.v4()}.$extension';
      final filePath = 'videos/$fileName';

      // Fazer upload para o Supabase Storage
      final bytes = await videoFile.readAsBytes();
      await SupabaseService.client.storage
          .from(_bucketName)
          .uploadBinary(filePath, bytes);

      // Obter URL pública
      final publicUrl = SupabaseService.client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao fazer upload do vídeo: $e');
      }
      throw Exception('Erro ao fazer upload do vídeo. Tente novamente.');
    }
  }

  /// Faz upload de dados de imagem (bytes)
  static Future<String?> uploadImageBytes(List<int> imageBytes, String extension) async {
    try {
      // Validar tamanho dos dados
      if (imageBytes.length > _maxImageSize) {
        throw Exception('Imagem muito grande. Tamanho máximo: 5MB');
      }

      // Validar tipo do arquivo
      if (!_allowedImageTypes.contains(extension.toLowerCase())) {
        throw Exception('Tipo de arquivo não suportado. Use: ${_allowedImageTypes.join(', ')}');
      }

      // Gerar nome único para o arquivo
      final fileName = '${_uuid.v4()}.$extension';
      final filePath = 'images/$fileName';

      // Fazer upload para o Supabase Storage
      await SupabaseService.client.storage
          .from(_bucketName)
          .uploadBinary(filePath, Uint8List.fromList(imageBytes));

      // Obter URL pública
      final publicUrl = SupabaseService.client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao fazer upload dos dados da imagem: $e');
      }
      throw Exception('Erro ao fazer upload da imagem. Tente novamente.');
    }
  }

  /// Remove um arquivo do storage
  static Future<void> deleteFile(String fileUrl) async {
    try {
      // Extrair o caminho do arquivo da URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 3) {
        final filePath = pathSegments.sublist(2).join('/');
        await SupabaseService.client.storage
            .from(_bucketName)
            .remove([filePath]);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao remover arquivo: $e');
      }
      // Não lança exceção para não quebrar o fluxo principal
    }
  }

  /// Remove múltiplos arquivos do storage
  static Future<void> deleteFiles(List<String> fileUrls) async {
    try {
      final List<String> filePaths = [];
      
      for (final fileUrl in fileUrls) {
        final uri = Uri.parse(fileUrl);
        final pathSegments = uri.pathSegments;
        
        if (pathSegments.length >= 3) {
          final filePath = pathSegments.sublist(2).join('/');
          filePaths.add(filePath);
        }
      }

      if (filePaths.isNotEmpty) {
        await SupabaseService.client.storage
            .from(_bucketName)
            .remove(filePaths);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao remover arquivos: $e');
      }
      // Não lança exceção para não quebrar o fluxo principal
    }
  }

  /// Valida se uma URL é de um arquivo válido
  static bool isValidFileUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https' && 
             uri.host.contains('supabase') && 
             uri.pathSegments.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtém informações sobre o arquivo
  static Map<String, dynamic> getFileInfo(String fileUrl) {
    try {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.isNotEmpty ? pathSegments.last : '';
      final extension = path.extension(fileName).toLowerCase();
      
      return {
        'url': fileUrl,
        'fileName': fileName,
        'extension': extension,
        'isImage': _allowedImageTypes.contains(extension.substring(1)),
        'isVideo': _allowedVideoTypes.contains(extension.substring(1)),
      };
    } catch (e) {
      return {
        'url': fileUrl,
        'fileName': '',
        'extension': '',
        'isImage': false,
        'isVideo': false,
      };
    }
  }
}
