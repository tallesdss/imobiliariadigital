import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../theme/app_theme.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onCompare;
  final bool isFavorite;
  final bool isCompact;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onFavorite,
    this.onCompare,
    this.isFavorite = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
        child: SizedBox(
          height: isCompact ? 320 : 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem do imóvel
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: property.photos.isNotEmpty
                            ? Image.network(
                                property.photos.first,
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
                    
                    // Badges
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        children: [
                          if (property.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'DESTAQUE',
                                style: AppTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (property.isLaunch) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'LANÇAMENTO',
                                style: AppTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Botão de favorito
                    if (onFavorite != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onFavorite,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey[600],
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Informações do imóvel
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        property.title,
                        style: AppTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Endereço
                      Text(
                        property.address,
                        style: AppTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Características
                      Row(
                        children: [
                          _buildFeature(
                            Icons.bed,
                            '${property.attributes['bedrooms'] ?? 0}',
                          ),
                          const SizedBox(width: 12),
                          _buildFeature(
                            Icons.bathtub,
                            '${property.attributes['bathrooms'] ?? 0}',
                          ),
                          const SizedBox(width: 12),
                          _buildFeature(
                            Icons.square_foot,
                            '${property.attributes['area'] ?? 0}m²',
                          ),
                          if (property.attributes['parkingSpaces'] != null && 
                              property.attributes['parkingSpaces'] != 0) ...[
                            const SizedBox(width: 12),
                            _buildFeature(
                              Icons.local_parking,
                              '${property.attributes['parkingSpaces']}',
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      
                      // Preço
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              property.formattedPrice,
                              style: AppTheme.titleSmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (property.transactionType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getTransactionTypeLabel(property.transactionType!),
                                style: AppTheme.bodySmall?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
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
  }

  Widget _buildFeature(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getTransactionTypeLabel(PropertyTransactionType type) {
    switch (type) {
      case PropertyTransactionType.sale:
        return 'Venda';
      case PropertyTransactionType.rent:
        return 'Aluguel';
      case PropertyTransactionType.daily:
        return 'Temporada';
    }
  }
}