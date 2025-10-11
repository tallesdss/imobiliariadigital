import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../models/search_model.dart';
import '../../services/image_search_service.dart' as image_service;
import '../../services/search_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/cards/property_card.dart';
import 'property_detail_screen.dart';
import 'search_results_screen.dart';

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  List<ImageSearchResult> _searchResults = [];
  image_service.ImageInfo? _imageInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: _selectedImage == null
                    ? _buildImageSelection()
                    : _buildImageAnalysis(),
              ),
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildResultsSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.camera_alt,
          size: 48,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          'Busca por Imagem',
          style: AppTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fotografe ou selecione uma imagem para encontrar imóveis similares',
          style: AppTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImageSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Selecione uma imagem',
                style: AppTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeria'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _captureImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Câmera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSuggestions(),
      ],
    );
  }

  Widget _buildImageAnalysis() {
    return Column(
      children: [
        // Imagem selecionada
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Informações da imagem
        if (_imageInfo != null) _buildImageInfo(),
        const SizedBox(height: 16),
        
        // Botão de busca
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _searchByImage,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(_isLoading ? 'Analisando...' : 'Buscar Imóveis Similares'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Botão para trocar imagem
        TextButton.icon(
          onPressed: _clearImage,
          icon: const Icon(Icons.refresh),
          label: const Text('Trocar Imagem'),
        ),
        
        if (_isLoading) ...[
          const SizedBox(height: 24),
          const LoadingWidget(),
        ],
        
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          CustomErrorWidget(message: _errorMessage!),
        ],
      ],
    );
  }

  Widget _buildImageInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações da Imagem',
              style: AppTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Arquivo:', style: AppTheme.bodySmall),
                Text(
                  _imageInfo!.fileName,
                  style: AppTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tamanho:', style: AppTheme.bodySmall),
                Text(
                  _imageInfo!.formattedFileSize,
                  style: AppTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Formato:', style: AppTheme.bodySmall),
                Text(
                  _imageInfo!.format.toUpperCase(),
                  style: AppTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (!_imageInfo!.isValidFormat || !_imageInfo!.isValidSize) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        !_imageInfo!.isValidFormat
                            ? 'Formato não suportado. Use JPG, PNG ou WebP.'
                            : 'Imagem muito grande. Máximo 5MB.',
                        style: AppTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imóveis Similares Encontrados',
          style: AppTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_searchResults.length} resultados baseados na análise da imagem',
          style: AppTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: Card(
                  child: InkWell(
                    onTap: () => _navigateToProperty(result.property),
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagem do imóvel
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: result.property.photos.isNotEmpty
                                  ? Image.network(
                                      result.property.photos.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.home,
                                          size: 40,
                                          color: Colors.grey,
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.home,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                        ),
                        
                        // Informações do imóvel
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.property.title,
                                  style: AppTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  result.property.formattedPrice,
                                  style: AppTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${(result.similarity * 100).toInt()}% similar',
                                    style: AppTheme.bodySmall?.copyWith(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _viewAllResults,
            icon: const Icon(Icons.list),
            label: const Text('Ver Todos os Resultados'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions() {
    final suggestions = image_service.ImageSearchService.getImageSearchSuggestions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dicas para melhor resultado:',
          style: AppTheme.titleSmall?.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.take(4).map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Colors.amber[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion,
                  style: AppTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final image = await image_service.ImageSearchService.pickImageFromGallery();
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _errorMessage = null;
          _searchResults.clear();
        });
        await _getImageInfo();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _captureImageFromCamera() async {
    try {
      final image = await image_service.ImageSearchService.captureImageFromCamera();
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _errorMessage = null;
          _searchResults.clear();
        });
        await _getImageInfo();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _getImageInfo() async {
    if (_selectedImage == null) return;

    try {
      final info = await image_service.ImageSearchService.getImageInfo(_selectedImage!);
      setState(() {
        _imageInfo = info;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao obter informações da imagem: $e';
      });
    }
  }

  Future<void> _searchByImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await image_service.ImageSearchService.searchByImage(_selectedImage!);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imageInfo = null;
      _searchResults.clear();
      _errorMessage = null;
    });
  }

  void _navigateToProperty(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(property: property),
      ),
    );
  }

  void _viewAllResults() {
    if (_searchResults.isEmpty) return;

    // Converter resultados para lista de propriedades
    final properties = _searchResults.map((result) => result.property).toList();
    
    // Criar query de busca baseada na imagem
    final searchQuery = SearchQuery(
      imageUrl: _selectedImage?.path,
      sortBy: 'relevance',
      sortAscending: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          searchQuery: searchQuery,
          results: properties,
        ),
      ),
    );
  }
}
