import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../services/property_state_service.dart';
import '../../services/favorite_service.dart';
import '../../services/notification_service.dart';
import '../../models/property_model.dart';
import '../../models/filter_model.dart';
import '../../widgets/cards/property_card.dart';
import '../../widgets/common/fixed_sidebar.dart';
import 'property_comparison_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  Set<String> _favoritePropertyIds = {};
  final Set<String> _comparePropertyIds = {};
  bool _showCarousels = true;
  bool _showOnlyLaunches = false;
  bool _sidebarVisible = true;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final propertyService = Provider.of<PropertyStateService>(context, listen: false);
    await propertyService.initialize();
    await propertyService.loadProperties(refresh: true);
    
    // Carregar favoritos do usuário
    try {
      await _loadUserFavorites();
    } catch (e) {
      // Ignora erro de favoritos
    }
    
    // Carregar notificações
    try {
      await _loadNotifications();
    } catch (e) {
      // Ignora erro de notificações
    }
  }

  Future<void> _loadUserFavorites() async {
    try {
      final favorites = await FavoriteService.getUserFavorites();
      if (mounted) {
        setState(() {
          _favoritePropertyIds = favorites.map((p) => p.id).toSet();
        });
      }
    } catch (e) {
      // Ignorar erros de favoritos na inicialização
      // O usuário pode não ter favoritos ainda
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      final unreadCount = await notificationService.getUnreadCount('user_id');
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = unreadCount;
        });
      }
    } catch (e) {
      // Ignorar erros de notificações na inicialização
    }
  }

  void _updateCarouselVisibility() {
    final propertyService = Provider.of<PropertyStateService>(context, listen: false);
    setState(() {
      _showCarousels = propertyService.searchQuery.isEmpty && 
          propertyService.selectedType == null && 
          !_showOnlyLaunches && 
          !propertyService.filters.hasActiveFilters;
    });
  }


  Future<void> _toggleFavorite(String propertyId) async {
    try {
      await FavoriteService.toggleFavorite(propertyId);
      
      setState(() {
        if (_favoritePropertyIds.contains(propertyId)) {
          _favoritePropertyIds.remove(propertyId);
        } else {
          _favoritePropertyIds.add(propertyId);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _favoritePropertyIds.contains(propertyId)
                  ? 'Imóvel adicionado aos favoritos'
                  : 'Imóvel removido dos favoritos',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar favorito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleCompare(String propertyId) {
    setState(() {
      if (_comparePropertyIds.contains(propertyId)) {
        _comparePropertyIds.remove(propertyId);
      } else if (_comparePropertyIds.length < 3) {
        _comparePropertyIds.add(propertyId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você pode comparar no máximo 3 imóveis'),
          ),
        );
      }
    });
  }

  Widget _buildMainContent() {
    if (_showCarousels) {
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            _buildCarousels(),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Todos os Imóveis',
                        style: AppTypography.h6.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Consumer<PropertyStateService>(
                        builder: (context, propertyService, child) {
                          return Text(
                            '${propertyService.allProperties.length} imóveis encontrados',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            _buildPropertiesGrid(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      );
    } else {
      return _buildPropertiesGrid();
    }
  }

  Widget _buildCarousels() {
    return Consumer<PropertyStateService>(
      builder: (context, propertyService, child) {
        // Separar propriedades por categoria
        final launches = propertyService.launchProperties;
        final houses = propertyService.allProperties.where((p) => p.type == PropertyType.house).toList();
        final apartments = propertyService.allProperties.where((p) => p.type == PropertyType.apartment).toList();

    return Column(
      children: [
        if (launches.isNotEmpty) ...[
          _buildCarousel('🚀 Lançamentos', launches, () {
            setState(() {
              _showOnlyLaunches = true;
            });
            propertyService.setSelectedType(null);
            _updateCarouselVisibility();
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (houses.isNotEmpty) ...[
          _buildCarousel('🏠 Casas', houses, () {
            setState(() {
              _showOnlyLaunches = false;
            });
            propertyService.setSelectedType(PropertyType.house);
            _updateCarouselVisibility();
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (apartments.isNotEmpty) ...[
          _buildCarousel('🏢 Apartamentos', apartments, () {
            setState(() {
              _showOnlyLaunches = false;
            });
            propertyService.setSelectedType(PropertyType.apartment);
            _updateCarouselVisibility();
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
      },
    );
  }

  Widget _buildCarousel(String title, List<Property> properties, VoidCallback onSeeAll) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 20,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'Ver todos',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: isTablet ? 380 : 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : AppSpacing.lg,
            ),
            itemCount: properties.length > (isTablet ? 6 : 5) ? (isTablet ? 6 : 5) : properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return Container(
                width: isTablet ? 300 : 280,
                margin: EdgeInsets.only(
                  right: index == properties.length - 1 ? 0 : AppSpacing.md,
                ),
                child: PropertyCard(
                  property: property,
                  isFavorite: _favoritePropertyIds.contains(property.id),
                  onTap: () => _navigateToPropertyDetail(property.id),
                  onFavorite: () => _toggleFavorite(property.id),
                  onCompare: () {},
                  isCompact: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToPropertyDetail(String propertyId) {
    if (kDebugMode) {
      debugPrint('Navegando para detalhes do imóvel: $propertyId');
    }
    context.go('/user/property/$propertyId');
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: const Text('Meu Perfil'),
              onTap: () {
                Navigator.pop(context);
                context.go('/user/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: AppColors.error),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
                context.go('/user/favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: AppColors.accent),
              title: const Text('Notificações'),
              onTap: () {
                Navigator.pop(context);
                context.go('/user/notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm, color: AppColors.accent),
              title: const Text('Alertas'),
              onTap: () {
                Navigator.pop(context);
                context.go('/user/alerts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppColors.primary),
              title: const Text('Mensagens'),
              onTap: () {
                Navigator.pop(context);
                context.go('/user/chat');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: AppColors.textSecondary,
              ),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configurações em desenvolvimento'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context);
                context.go('/login');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToComparison() {
    // TODO: Implementar rota para comparação de propriedades
    // Por enquanto, usar Navigator.push até implementar a rota no GoRouter
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PropertyComparisonScreen(propertyIds: _comparePropertyIds.toList()),
      ),
    );
  }

  void _onFiltersChanged(PropertyFilters filters) {
    final propertyService = Provider.of<PropertyStateService>(context, listen: false);
    propertyService.setFilters(filters);
    _updateCarouselVisibility();
  }

  void _onClearFilters() {
    final propertyService = Provider.of<PropertyStateService>(context, listen: false);
    propertyService.clearFilters();
    setState(() {
      _showOnlyLaunches = false;
    });
    _updateCarouselVisibility();
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyStateService>(
      builder: (context, propertyService, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: Row(
            children: [
              // Sidebar fixa de filtros
              FixedSidebar(
                type: SidebarType.filters,
                currentRoute: '/user',
                filters: propertyService.filters,
                onFiltersChanged: _onFiltersChanged,
                onClearFilters: _onClearFilters,
                isVisible: _sidebarVisible,
                onToggleVisibility: () {
                  setState(() {
                    _sidebarVisible = !_sidebarVisible;
                  });
                },
              ),
              
              // Conteúdo principal
              Expanded(
                child: Column(
                  children: [
                    _buildSearchAndFilters(),
                    _buildCompareBar(),
                    Expanded(
                      child: propertyService.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildMainContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
          title: Row(
            children: [
              const Icon(Icons.home_work, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'SC IMÓVEIS',
                style: AppTypography.h6.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          actions: [
            // Botão para alternar sidebar
            IconButton(
              onPressed: () {
                setState(() {
                  _sidebarVisible = !_sidebarVisible;
                });
              },
              icon: Icon(_sidebarVisible ? Icons.menu_open : Icons.menu),
              tooltip: _sidebarVisible ? 'Ocultar filtros' : 'Mostrar filtros',
            ),
            // Indicador de filtros ativos
            Consumer<PropertyStateService>(
              builder: (context, propertyService, child) {
                if (propertyService.filters.hasActiveFilters) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.filter_list,
                          color: AppColors.textOnPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Filtros Ativos',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            IconButton(
              onPressed: () {
                context.go('/user/notifications');
              },
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined),
                  if (_unreadNotificationsCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$_unreadNotificationsCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context.go('/user/favorites');
              },
              icon: Stack(
                children: [
                  const Icon(Icons.favorite_outline),
                  if (_favoritePropertyIds.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${_favoritePropertyIds.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: _showUserMenu,
              icon: const Icon(Icons.account_circle),
            ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Consumer<PropertyStateService>(
      builder: (context, propertyService, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        
        return Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra de pesquisa com botão de filtros
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        propertyService.setSearchQuery(value);
                        _updateCarouselVisibility();
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar imóvel...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: propertyService.searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  propertyService.setSearchQuery('');
                                  _updateCarouselVisibility();
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 12,
                          vertical: isTablet ? 16 : 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Filtros de tipo
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todos', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('Casas', PropertyType.house),
                    const SizedBox(width: 8),
                    _buildFilterChip('Apartamentos', PropertyType.apartment),
                    const SizedBox(width: 8),
                    _buildFilterChip('Comercial', PropertyType.commercial),
                    const SizedBox(width: 8),
                    _buildFilterChip('Terrenos', PropertyType.land),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, PropertyType? type) {
    return Consumer<PropertyStateService>(
      builder: (context, propertyService, child) {
        final isSelected = propertyService.selectedType == type;
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            propertyService.setSelectedType(selected ? type : null);
            _updateCarouselVisibility();
          },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
      },
    );
  }

  Widget _buildCompareBar() {
    if (_comparePropertyIds.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.accent.withValues(alpha: 0.1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_comparePropertyIds.length} imóveis selecionados para comparar',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accentDark,
              ),
            ),
          ),
          TextButton(
            onPressed: _comparePropertyIds.length >= 2
                ? _navigateToComparison
                : null,
            child: Text(
              'Comparar',
              style: AppTypography.labelMedium.copyWith(
                color: _comparePropertyIds.length >= 2
                    ? AppColors.accentDark
                    : AppColors.textHint,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _comparePropertyIds.clear();
              });
            },
            child: Text(
              'Limpar',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesGrid() {
    return Consumer<PropertyStateService>(
      builder: (context, propertyService, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1024;
        
        // Usar allProperties quando não há filtros ativos para mostrar todos os imóveis
        final propertiesToShow = (propertyService.searchQuery.isEmpty && 
                                propertyService.selectedType == null && 
                                !propertyService.filters.hasActiveFilters) 
                                ? propertyService.allProperties 
                                : propertyService.filteredProperties;
        
        if (propertiesToShow.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 32 : AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off, 
                    size: isTablet ? 80 : 64, 
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: isTablet ? 24 : AppSpacing.md),
                  Text(
                    'Nenhum imóvel encontrado',
                    style: AppTypography.h6.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 20 : 18,
                    ),
                  ),
                  SizedBox(height: isTablet ? 12 : AppSpacing.sm),
                  Text(
                    'Tente ajustar os filtros de busca',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textHint,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Sempre usar grade responsiva para melhor experiência
        return GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppSpacing.md : isTablet ? 24 : 32,
            vertical: AppSpacing.md,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(screenWidth),
            childAspectRatio: _getChildAspectRatio(screenWidth),
            crossAxisSpacing: isMobile ? AppSpacing.sm : AppSpacing.md,
            mainAxisSpacing: isMobile ? AppSpacing.sm : AppSpacing.md,
          ),
          itemCount: propertiesToShow.length,
          itemBuilder: (context, index) {
            final property = propertiesToShow[index];
            return PropertyCard(
              property: property,
              isFavorite: _favoritePropertyIds.contains(property.id),
              onTap: () => _navigateToPropertyDetail(property.id),
              onFavorite: () => _toggleFavorite(property.id),
              onCompare: () => _toggleCompare(property.id),
              isCompact: isMobile, // Usar versão compacta em mobile
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) {
      return 1; // Mobile: 1 coluna
    } else if (screenWidth < 900) {
      return 2; // Tablet pequeno: 2 colunas
    } else if (screenWidth < 1200) {
      return 3; // Tablet grande: 3 colunas
    } else if (screenWidth < 1600) {
      return 4; // Desktop pequeno: 4 colunas
    } else {
      return 5; // Desktop grande: 5 colunas
    }
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth < 600) {
      return 1.2; // Mobile: formato mais retangular
    } else if (screenWidth < 900) {
      return 0.85; // Tablet pequeno: formato mais quadrado
    } else if (screenWidth < 1200) {
      return 0.8; // Tablet grande: formato quadrado
    } else {
      return 0.75; // Desktop: formato mais vertical
    }
  }
}

