import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/mock_data_service.dart';
import '../../models/property_model.dart';
import '../../widgets/cards/property_card.dart';
import 'property_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Property> _favoriteProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _isLoading = true;
    });

    // Simular carregamento
    Future.delayed(const Duration(milliseconds: 500), () {
      final favorites = MockDataService.getFavoriteProperties('user1');
      setState(() {
        _favoriteProperties = favorites;
        _isLoading = false;
      });
    });
  }

  void _removeFavorite(String propertyId) {
    MockDataService.removeFavorite('user1', propertyId);
    setState(() {
      _favoriteProperties.removeWhere((property) => property.id == propertyId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imóvel removido dos favoritos')),
    );
  }

  void _navigateToPropertyDetail(String propertyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(propertyId: propertyId),
      ),
    ).then((_) {
      // Recarregar favoritos quando voltar da tela de detalhes
      _loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          if (_favoriteProperties.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Limpar Favoritos'),
                    content: const Text(
                      'Tem certeza que deseja remover todos os imóveis dos favoritos?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearAllFavorites();
                        },
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Limpar',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_favoriteProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum favorito ainda',
              style: AppTypography.h6.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione imóveis aos favoritos para vê-los aqui',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.search),
              label: const Text('Buscar Imóveis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header com contador
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                '${_favoriteProperties.length} ${_favoriteProperties.length == 1 ? 'imóvel favorito' : 'imóveis favoritos'}',
                style: AppTypography.labelLarge,
              ),
            ],
          ),
        ),
        // Lista de favoritos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _favoriteProperties.length,
            itemBuilder: (context, index) {
              final property = _favoriteProperties[index];
              return GestureDetector(
                onTap: () => _navigateToPropertyDetail(property.id),
                child: PropertyCard(
                  property: property,
                  isFavorite: true,
                  onFavoriteToggle: () => _removeFavorite(property.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _clearAllFavorites() {
    for (final property in _favoriteProperties) {
      MockDataService.removeFavorite('user1', property.id);
    }

    setState(() {
      _favoriteProperties.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todos os favoritos foram removidos')),
    );
  }
}
