import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../models/property_model.dart';
import '../cards/property_card.dart';

class HorizontalCarousel extends StatelessWidget {
  final String title;
  final List<Property> properties;
  final Function(String) onPropertyTap;
  final Function(String) onFavoriteToggle;
  final Set<String> favoritePropertyIds;
  final VoidCallback? onSeeAll;

  const HorizontalCarousel({
    super.key,
    required this.title,
    required this.properties,
    required this.onPropertyTap,
    required this.onFavoriteToggle,
    required this.favoritePropertyIds,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAll != null)
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
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right: index == properties.length - 1 ? 0 : AppSpacing.md,
                ),
                child: GestureDetector(
                  onTap: () => onPropertyTap(property.id),
                  child: PropertyCard(
                    property: property,
                    isFavorite: favoritePropertyIds.contains(property.id),
                    onFavoriteToggle: () => onFavoriteToggle(property.id),
                    onCompare: () {}, // Não usado no carrossel
                    isCompact: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoryCarouselSection extends StatelessWidget {
  final List<Property> allProperties;
  final Function(String) onPropertyTap;
  final Function(String) onFavoriteToggle;
  final Set<String> favoritePropertyIds;

  const CategoryCarouselSection({
    super.key,
    required this.allProperties,
    required this.onPropertyTap,
    required this.onFavoriteToggle,
    required this.favoritePropertyIds,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrar propriedades por categorias
    final launchProperties = allProperties
        .where((p) => p.isLaunch && p.status == PropertyStatus.active)
        .take(10)
        .toList();
    
    final houseProperties = allProperties
        .where((p) => p.type == PropertyType.house && p.status == PropertyStatus.active)
        .take(10)
        .toList();
    
    final apartmentProperties = allProperties
        .where((p) => p.type == PropertyType.apartment && p.status == PropertyStatus.active)
        .take(10)
        .toList();
    
    final commercialProperties = allProperties
        .where((p) => p.type == PropertyType.commercial && p.status == PropertyStatus.active)
        .take(10)
        .toList();

    return Column(
      children: [
        if (launchProperties.isNotEmpty) ...[
          HorizontalCarousel(
            title: '🚀 Lançamentos',
            properties: launchProperties,
            onPropertyTap: onPropertyTap,
            onFavoriteToggle: onFavoriteToggle,
            favoritePropertyIds: favoritePropertyIds,
            onSeeAll: () {
              // TODO: Implementar filtro por lançamentos
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (houseProperties.isNotEmpty) ...[
          HorizontalCarousel(
            title: '🏠 Casas',
            properties: houseProperties,
            onPropertyTap: onPropertyTap,
            onFavoriteToggle: onFavoriteToggle,
            favoritePropertyIds: favoritePropertyIds,
            onSeeAll: () {
              // TODO: Implementar filtro por casas
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (apartmentProperties.isNotEmpty) ...[
          HorizontalCarousel(
            title: '🏢 Apartamentos',
            properties: apartmentProperties,
            onPropertyTap: onPropertyTap,
            onFavoriteToggle: onFavoriteToggle,
            favoritePropertyIds: favoritePropertyIds,
            onSeeAll: () {
              // TODO: Implementar filtro por apartamentos
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (commercialProperties.isNotEmpty) ...[
          HorizontalCarousel(
            title: '🏪 Comercial',
            properties: commercialProperties,
            onPropertyTap: onPropertyTap,
            onFavoriteToggle: onFavoriteToggle,
            favoritePropertyIds: favoritePropertyIds,
            onSeeAll: () {
              // TODO: Implementar filtro por comercial
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }
}
