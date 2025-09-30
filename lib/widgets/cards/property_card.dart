import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onCompare;
  final bool isCompact;

  const PropertyCard({
    super.key,
    required this.property,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onCompare,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          _buildContentSection(),
          _buildAttributesSection(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Container(
            height: isCompact ? 150 : 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              image: property.photos.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(property.photos.first),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    )
                  : null,
            ),
            child: property.photos.isEmpty
                ? const Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  )
                : null,
          ),
        ),
        // Código do imóvel
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Cód: ${property.id.substring(0, 5)}',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Botões de ação
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: [
              if (onCompare != null && !isCompact)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: onCompare,
                    icon: const Icon(Icons.compare_arrows),
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              if (onCompare != null && !isCompact) const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : AppColors.textSecondary,
                  ),
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo do imóvel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              property.typeDisplayName,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Título
          Text(
            property.title,
            style: AppTypography.h6,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Localização
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${property.city}, ${property.state}',
                  style: AppTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Preço
          Text(
            property.formattedPrice,
            style: AppTypography.priceSecondary,
          ),
          const SizedBox(height: 8),
          // Descrição resumida
          if (property.description.isNotEmpty)
            Text(
              property.description,
              style: AppTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildAttributesSection() {
    final attributes = <Widget>[];
    
    if (property.attributes['bedrooms'] != null) {
      attributes.add(_buildAttributeItem(
        Icons.bed_outlined,
        '${property.attributes['bedrooms']}',
        'quartos',
      ));
    }
    
    if (property.attributes['bathrooms'] != null) {
      attributes.add(_buildAttributeItem(
        Icons.bathroom_outlined,
        '${property.attributes['bathrooms']}',
        'banheiros',
      ));
    }
    
    if (property.attributes['area'] != null) {
      attributes.add(_buildAttributeItem(
        Icons.square_foot_outlined,
        '${property.attributes['area']}m²',
        '',
      ));
    }
    
    if (property.attributes['parking'] != null) {
      attributes.add(_buildAttributeItem(
        Icons.directions_car_outlined,
        '${property.attributes['parking']}',
        'vagas',
      ));
    }

    if (attributes.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: attributes.take(4).toList(),
      ),
    );
  }

  Widget _buildAttributeItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelMedium,
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: AppTypography.overline,
          ),
      ],
    );
  }
}
