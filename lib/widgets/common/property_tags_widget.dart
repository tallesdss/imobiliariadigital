import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Widget para exibir tags de um imóvel
class PropertyTagsWidget extends StatelessWidget {
  final List<PropertyTag> tags;
  final int? maxTags;
  final bool showAll;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsets? padding;
  final double? spacing;

  const PropertyTagsWidget({
    super.key,
    required this.tags,
    this.maxTags,
    this.showAll = false,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.padding,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayTags = _getDisplayTags();
    
    return GestureDetector(
      onTap: onTap,
      child: Wrap(
        spacing: spacing ?? 8.0,
        runSpacing: spacing ?? 4.0,
        children: displayTags.map((tag) {
          return _buildTagChip(tag);
        }).toList(),
      ),
    );
  }

  List<PropertyTag> _getDisplayTags() {
    if (showAll || maxTags == null) {
      return tags;
    }
    
    return tags.take(maxTags!).toList();
  }

  Widget _buildTagChip(PropertyTag tag) {
    final tagInfo = _getTagInfo(tag);
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? tagInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tagInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tagInfo.icon != null) ...[
            Icon(
              tagInfo.icon,
              size: (fontSize ?? 12) + 2,
              color: textColor ?? tagInfo.color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            _getTagDisplayName(tag),
            style: AppTypography.bodySmall.copyWith(
              color: textColor ?? tagInfo.color,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  TagInfo _getTagInfo(PropertyTag tag) {
    switch (tag) {
      // Tags de destaque
      case PropertyTag.featured:
        return TagInfo(
          color: Colors.amber,
          icon: Icons.star,
        );
      case PropertyTag.launch:
        return TagInfo(
          color: Colors.green,
          icon: Icons.rocket_launch,
        );
      case PropertyTag.newProperty:
        return TagInfo(
          color: Colors.blue,
          icon: Icons.new_releases,
        );
      case PropertyTag.hotDeal:
        return TagInfo(
          color: Colors.red,
          icon: Icons.local_fire_department,
        );
      case PropertyTag.exclusive:
        return TagInfo(
          color: Colors.purple,
          icon: Icons.diamond,
        );
      
      // Tags de características
      case PropertyTag.furnished:
        return TagInfo(
          color: Colors.brown,
          icon: Icons.chair,
        );
      case PropertyTag.unfurnished:
        return TagInfo(
          color: Colors.grey,
          icon: Icons.chair_outlined,
        );
      case PropertyTag.petFriendly:
        return TagInfo(
          color: Colors.orange,
          icon: Icons.pets,
        );
      case PropertyTag.hasPool:
        return TagInfo(
          color: Colors.cyan,
          icon: Icons.pool,
        );
      case PropertyTag.hasGym:
        return TagInfo(
          color: Colors.deepOrange,
          icon: Icons.fitness_center,
        );
      case PropertyTag.hasSecurity:
        return TagInfo(
          color: Colors.indigo,
          icon: Icons.security,
        );
      case PropertyTag.hasGarage:
        return TagInfo(
          color: Colors.blueGrey,
          icon: Icons.local_parking,
        );
      case PropertyTag.hasGarden:
        return TagInfo(
          color: Colors.green,
          icon: Icons.local_florist,
        );
      case PropertyTag.hasBalcony:
        return TagInfo(
          color: Colors.teal,
          icon: Icons.balcony,
        );
      case PropertyTag.hasElevator:
        return TagInfo(
          color: Colors.grey,
          icon: Icons.elevator,
        );
      
      // Tags de localização
      case PropertyTag.nearMetro:
        return TagInfo(
          color: Colors.blue,
          icon: Icons.train,
        );
      case PropertyTag.nearSchool:
        return TagInfo(
          color: Colors.amber,
          icon: Icons.school,
        );
      case PropertyTag.nearHospital:
        return TagInfo(
          color: Colors.red,
          icon: Icons.local_hospital,
        );
      case PropertyTag.nearShopping:
        return TagInfo(
          color: Colors.pink,
          icon: Icons.shopping_bag,
        );
      case PropertyTag.beachfront:
        return TagInfo(
          color: Colors.cyan,
          icon: Icons.beach_access,
        );
      case PropertyTag.downtown:
        return TagInfo(
          color: Colors.indigo,
          icon: Icons.location_city,
        );
      case PropertyTag.quietArea:
        return TagInfo(
          color: Colors.green,
          icon: Icons.nature,
        );
      
      // Tags de financiamento
      case PropertyTag.acceptsProposal:
        return TagInfo(
          color: Colors.green,
          icon: Icons.handshake,
        );
      case PropertyTag.hasFinancing:
        return TagInfo(
          color: Colors.blue,
          icon: Icons.account_balance,
        );
      case PropertyTag.cashOnly:
        return TagInfo(
          color: Colors.orange,
          icon: Icons.money,
        );
      case PropertyTag.rentToOwn:
        return TagInfo(
          color: Colors.purple,
          icon: Icons.trending_up,
        );
      
      // Tags de urgência
      case PropertyTag.urgent:
        return TagInfo(
          color: Colors.red,
          icon: Icons.priority_high,
        );
      case PropertyTag.priceReduced:
        return TagInfo(
          color: Colors.green,
          icon: Icons.trending_down,
        );
      case PropertyTag.motivatedSeller:
        return TagInfo(
          color: Colors.orange,
          icon: Icons.sell,
        );
      
      // Tags especiais
      case PropertyTag.heritage:
        return TagInfo(
          color: Colors.brown,
          icon: Icons.museum,
        );
      case PropertyTag.ecoFriendly:
        return TagInfo(
          color: Colors.green,
          icon: Icons.eco,
        );
      case PropertyTag.smartHome:
        return TagInfo(
          color: Colors.blue,
          icon: Icons.smart_toy,
        );
      case PropertyTag.renovated:
        return TagInfo(
          color: Colors.amber,
          icon: Icons.build,
        );
      case PropertyTag.needsRenovation:
        return TagInfo(
          color: Colors.grey,
          icon: Icons.construction,
        );
    }
  }

  String _getTagDisplayName(PropertyTag tag) {
    switch (tag) {
      // Tags de destaque
      case PropertyTag.featured:
        return 'Destaque';
      case PropertyTag.launch:
        return 'Lançamento';
      case PropertyTag.newProperty:
        return 'Novo';
      case PropertyTag.hotDeal:
        return 'Oferta Quente';
      case PropertyTag.exclusive:
        return 'Exclusivo';
      
      // Tags de características
      case PropertyTag.furnished:
        return 'Mobiliado';
      case PropertyTag.unfurnished:
        return 'Não Mobiliado';
      case PropertyTag.petFriendly:
        return 'Pet Friendly';
      case PropertyTag.hasPool:
        return 'Com Piscina';
      case PropertyTag.hasGym:
        return 'Com Academia';
      case PropertyTag.hasSecurity:
        return 'Com Segurança';
      case PropertyTag.hasGarage:
        return 'Com Garagem';
      case PropertyTag.hasGarden:
        return 'Com Jardim';
      case PropertyTag.hasBalcony:
        return 'Com Varanda';
      case PropertyTag.hasElevator:
        return 'Com Elevador';
      
      // Tags de localização
      case PropertyTag.nearMetro:
        return 'Próximo ao Metrô';
      case PropertyTag.nearSchool:
        return 'Próximo à Escola';
      case PropertyTag.nearHospital:
        return 'Próximo ao Hospital';
      case PropertyTag.nearShopping:
        return 'Próximo ao Shopping';
      case PropertyTag.beachfront:
        return 'Frente para o Mar';
      case PropertyTag.downtown:
        return 'Centro';
      case PropertyTag.quietArea:
        return 'Área Tranquila';
      
      // Tags de financiamento
      case PropertyTag.acceptsProposal:
        return 'Aceita Proposta';
      case PropertyTag.hasFinancing:
        return 'Tem Financiamento';
      case PropertyTag.cashOnly:
        return 'Apenas à Vista';
      case PropertyTag.rentToOwn:
        return 'Renda para Compra';
      
      // Tags de urgência
      case PropertyTag.urgent:
        return 'Urgente';
      case PropertyTag.priceReduced:
        return 'Preço Reduzido';
      case PropertyTag.motivatedSeller:
        return 'Vendedor Motivado';
      
      // Tags especiais
      case PropertyTag.heritage:
        return 'Patrimônio';
      case PropertyTag.ecoFriendly:
        return 'Eco-Friendly';
      case PropertyTag.smartHome:
        return 'Casa Inteligente';
      case PropertyTag.renovated:
        return 'Reformado';
      case PropertyTag.needsRenovation:
        return 'Precisa Reforma';
    }
  }
}

/// Classe para armazenar informações de uma tag
class TagInfo {
  final Color color;
  final IconData? icon;

  const TagInfo({
    required this.color,
    this.icon,
  });
}

/// Widget compacto para exibir apenas algumas tags principais
class PropertyTagsCompactWidget extends StatelessWidget {
  final List<PropertyTag> tags;
  final int maxTags;

  const PropertyTagsCompactWidget({
    super.key,
    required this.tags,
    this.maxTags = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayTags = tags.take(maxTags).toList();
    final hasMore = tags.length > maxTags;

    return Row(
      children: [
        ...displayTags.map((tag) => _buildCompactTag(tag)),
        if (hasMore)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${tags.length - maxTags}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactTag(PropertyTag tag) {
    final tagInfo = _getTagInfo(tag);
    
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tagInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getTagDisplayName(tag),
        style: AppTypography.bodySmall.copyWith(
          color: tagInfo.color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  TagInfo _getTagInfo(PropertyTag tag) {
    // Reutilizar a lógica do widget principal
    final widget = PropertyTagsWidget(tags: [tag]);
    return widget._getTagInfo(tag);
  }

  String _getTagDisplayName(PropertyTag tag) {
    // Reutilizar a lógica do widget principal
    final widget = PropertyTagsWidget(tags: [tag]);
    return widget._getTagDisplayName(tag);
  }
}
