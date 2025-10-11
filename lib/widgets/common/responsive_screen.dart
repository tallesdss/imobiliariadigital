import 'package:flutter/material.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_colors.dart';
import '../../models/filter_model.dart';
import 'fixed_sidebar.dart';
import 'responsive_layout.dart';
import 'custom_drawer.dart';

/// Widget base para telas responsivas com sidebar
class ResponsiveScreen extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final SidebarType sidebarType;
  final DrawerUserType? userType;
  final String? userName;
  final String? userEmail;
  final String? userAvatar;
  final String? userCreci;
  final String currentRoute;
  final PropertyFilters? filters;
  final Function(PropertyFilters)? onFiltersChanged;
  final VoidCallback? onClearFilters;
  final bool showSidebar;
  final Widget? drawer;

  const ResponsiveScreen({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.sidebarType = SidebarType.navigation,
    this.userType,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.userCreci,
    required this.currentRoute,
    this.filters,
    this.onFiltersChanged,
    this.onClearFilters,
    this.showSidebar = true,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.mobile) {
          return _buildMobileLayout(context);
        } else {
          return _buildDesktopLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: actions,
      ),
      drawer: drawer ?? (showSidebar ? _buildMobileDrawer(context) : null),
      body: child,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          if (showSidebar)
            IconButton(
              onPressed: () {
                // Implementar toggle da sidebar
              },
              icon: const Icon(Icons.menu),
              tooltip: 'Alternar menu',
            ),
          ...?actions,
        ],
      ),
      body: showSidebar
          ? Row(
              children: [
                FixedSidebar(
                  type: sidebarType,
                  userType: userType,
                  userName: userName,
                  userEmail: userEmail,
                  userAvatar: userAvatar,
                  userCreci: userCreci,
                  currentRoute: currentRoute,
                  filters: filters,
                  onFiltersChanged: onFiltersChanged,
                  onClearFilters: onClearFilters,
                  isVisible: true,
                ),
                Expanded(child: child),
              ],
            )
          : child,
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: FixedSidebar(
        type: sidebarType,
        userType: userType,
        userName: userName,
        userEmail: userEmail,
        userAvatar: userAvatar,
        userCreci: userCreci,
        currentRoute: currentRoute,
        filters: filters,
        onFiltersChanged: onFiltersChanged,
        onClearFilters: onClearFilters,
        isVisible: true,
      ),
    );
  }
}

/// Widget para dashboard responsivo
class ResponsiveDashboard extends StatelessWidget {
  final List<Widget> cards;
  final String title;
  final List<Widget>? actions;

  const ResponsiveDashboard({
    super.key,
    required this.cards,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return SingleChildScrollView(
          padding: context.responsivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: context.responsiveSpacing()),
              _buildCardsGrid(context, deviceType),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }

  Widget _buildCardsGrid(BuildContext context, DeviceType deviceType) {

    return ResponsiveGrid(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
      largeDesktopColumns: 4,
      spacing: context.responsiveSpacing(mobile: 12, tablet: 16, desktop: 20),
      runSpacing: context.responsiveSpacing(mobile: 12, tablet: 16, desktop: 20),
      children: cards,
    );
  }
}

/// Widget para listas responsivas
class ResponsiveList extends StatelessWidget {
  final List<Widget> items;
  final bool isScrollable;
  final EdgeInsets? padding;

  const ResponsiveList({
    super.key,
    required this.items,
    this.isScrollable = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final listWidget = ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(
        height: context.responsiveSpacing(mobile: 8, tablet: 12, desktop: 16),
      ),
      itemBuilder: (context, index) => items[index],
    );

    if (isScrollable) {
      return Padding(
        padding: padding ?? context.responsivePadding,
        child: listWidget,
      );
    }

    return Padding(
      padding: padding ?? context.responsivePadding,
      child: Column(
        children: items.expand((item) => [
          item,
          SizedBox(height: context.responsiveSpacing(mobile: 8, tablet: 12, desktop: 16)),
        ]).toList()..removeLast(),
      ),
    );
  }
}

/// Widget para tabelas responsivas
class ResponsiveTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String? title;
  final bool isScrollable;

  const ResponsiveTable({
    super.key,
    required this.columns,
    required this.rows,
    this.title,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.mobile) {
          return _buildMobileTable(context);
        } else {
          return _buildDesktopTable(context);
        }
      },
    );
  }

  Widget _buildMobileTable(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.responsiveSpacing()),
        ],
        ...rows.map((row) => ResponsiveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: row.cells.asMap().entries.map((entry) {
              final index = entry.key;
              final cell = entry.value;
              if (index >= columns.length) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      columns[index].label.toString(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    cell.child,
                  ],
                ),
              );
            }).toList(),
          ),
        )),
      ],
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.responsiveSpacing()),
          ],
          if (isScrollable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: columns,
                rows: rows,
              ),
            )
          else
            DataTable(
              columns: columns,
              rows: rows,
            ),
        ],
      ),
    );
  }
}
