import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/favorite_service.dart';
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

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tentar carregar do cache primeiro para melhor UX
      final cachedFavorites = FavoriteService.getCachedFavorites();
      if (cachedFavorites != null && cachedFavorites.isNotEmpty) {
        setState(() {
          _favoriteProperties = cachedFavorites;
          _isLoading = false;
        });
      }

      // Carregar dados atualizados da API
      final favorites = await FavoriteService.getUserFavorites();
      if (mounted) {
        setState(() {
          _favoriteProperties = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Se não há favoritos em cache, mostrar estado vazio
        if (_favoriteProperties.isEmpty) {
          // Não mostrar erro se não há favoritos - é um estado válido
          return;
        }
        
        // Mostrar erro apenas se havia favoritos em cache
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar favoritos: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: Colors.white,
              onPressed: _loadFavorites,
            ),
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(String propertyId) async {
    try {
      await FavoriteService.removeFavorite(propertyId);
      
      if (mounted) {
        setState(() {
          _favoriteProperties.removeWhere((property) => property.id == propertyId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imóvel removido dos favoritos'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover favorito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToPropertyDetail(String propertyId) {
    if (kDebugMode) {
      debugPrint('=== NAVEGAÇÃO DE FAVORITOS ===');
      debugPrint('Property ID: $propertyId');
      debugPrint('Rota completa: /user/property/$propertyId');
      debugPrint('Context: ${context.runtimeType}');
    }
    
    try {
      context.go('/user/property/$propertyId');
      if (kDebugMode) {
        debugPrint('✅ Navegação executada com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro na navegação: $e');
      }
      
      // Fallback: tentar com Navigator.push
      try {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(propertyId: propertyId),
          ),
        );
        if (kDebugMode) {
          debugPrint('✅ Fallback Navigator.push executado com sucesso');
        }
      } catch (fallbackError) {
        if (kDebugMode) {
          debugPrint('❌ Erro no fallback Navigator.push: $fallbackError');
        }
        
        // Mostrar erro para o usuário
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir detalhes do imóvel: $fallbackError'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          IconButton(
            onPressed: _loadFavorites,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar favoritos',
          ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;
    
    if (_favoriteProperties.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: isTablet ? 80 : 64,
                color: AppColors.textHint,
              ),
              SizedBox(height: isTablet ? 24 : 16),
              Text(
                'Nenhum favorito ainda',
                style: AppTypography.h6.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 20 : 18,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Adicione imóveis aos favoritos para vê-los aqui',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHint,
                  fontSize: isTablet ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 32 : 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar Imóveis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 20,
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  OutlinedButton.icon(
                    onPressed: _loadFavorites,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Atualizar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 20,
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header com contador
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          color: Colors.white,
          child: Row(
            children: [
              Icon(
                Icons.favorite, 
                color: Colors.red,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                '${_favoriteProperties.length} ${_favoriteProperties.length == 1 ? 'imóvel favorito' : 'imóveis favoritos'}',
                style: AppTypography.labelLarge.copyWith(
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ],
          ),
        ),
        // Lista de favoritos
        Expanded(
          child: isTablet && _favoriteProperties.length > 2
              ? GridView.builder(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _favoriteProperties.length,
                  itemBuilder: (context, index) {
                    final property = _favoriteProperties[index];
                    return PropertyCard(
                      property: property,
                      isFavorite: true,
                      onTap: () => _navigateToPropertyDetail(property.id),
                      onFavorite: () => _removeFavorite(property.id),
                    );
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  itemCount: _favoriteProperties.length,
                  itemBuilder: (context, index) {
                    final property = _favoriteProperties[index];
                    return PropertyCard(
                      property: property,
                      isFavorite: true,
                      onTap: () => _navigateToPropertyDetail(property.id),
                      onFavorite: () => _removeFavorite(property.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _clearAllFavorites() async {
    try {
      // Remover todos os favoritos em paralelo
      await Future.wait(
        _favoriteProperties.map((property) => 
          FavoriteService.removeFavorite(property.id)
        ),
      );

      if (mounted) {
        setState(() {
          _favoriteProperties.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos os favoritos foram removidos'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao limpar favoritos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
