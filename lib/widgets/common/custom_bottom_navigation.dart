import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum UserNavigationTab { home, search, favorites, alerts, chat }

class CustomBottomNavigation extends StatelessWidget {
  final UserNavigationTab currentTab;
  final Function(UserNavigationTab) onTabChanged;

  const CustomBottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                UserNavigationTab.home,
                Icons.home_outlined,
                Icons.home,
                'Início',
              ),
              _buildNavItem(
                UserNavigationTab.search,
                Icons.search_outlined,
                Icons.search,
                'Buscar',
              ),
              _buildNavItem(
                UserNavigationTab.favorites,
                Icons.favorite_outline,
                Icons.favorite,
                'Favoritos',
              ),
              _buildNavItem(
                UserNavigationTab.alerts,
                Icons.notifications_outlined,
                Icons.notifications,
                'Alertas',
              ),
              _buildNavItem(
                UserNavigationTab.chat,
                Icons.chat_bubble_outline,
                Icons.chat_bubble,
                'Chat',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    UserNavigationTab tab,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = currentTab == tab;

    return GestureDetector(
      onTap: () => onTabChanged(tab),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textHint,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
