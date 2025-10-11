import 'package:flutter/material.dart';
import '../../theme/app_breakpoints.dart';

/// Widget responsivo que adapta seu conteúdo baseado no tamanho da tela
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Widget que mostra diferentes layouts baseado no breakpoint
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, context.deviceType);
  }
}

/// Widget para layouts de grid responsivo
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    int columns;
    
    switch (deviceType) {
      case DeviceType.mobile:
        columns = mobileColumns ?? 1;
        break;
      case DeviceType.tablet:
        columns = tabletColumns ?? 2;
        break;
      case DeviceType.desktop:
        columns = desktopColumns ?? 3;
        break;
      case DeviceType.largeDesktop:
        columns = largeDesktopColumns ?? 4;
        break;
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 
                 (spacing * (columns - 1)) - 
                 (context.responsivePadding.horizontal)) / columns,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Widget para sidebar responsiva
class ResponsiveSidebar extends StatelessWidget {
  final Widget child;
  final bool isVisible;
  final VoidCallback? onToggleVisibility;

  const ResponsiveSidebar({
    super.key,
    required this.child,
    required this.isVisible,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      // Em mobile, a sidebar vira um drawer
      return Drawer(
        child: child,
      );
    }

    // Em tablets e desktops, sidebar fixa
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isVisible ? context.sidebarWidth : 60,
      child: child,
    );
  }
}

/// Widget para conteúdo principal responsivo
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final bool hasSidebar;
  final bool sidebarVisible;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.hasSidebar = true,
    this.sidebarVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile || !hasSidebar) {
      return child;
    }

    return Expanded(
      child: child,
    );
  }
}

/// Widget para formulários responsivos
class ResponsiveForm extends StatelessWidget {
  final Widget child;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveForm({
    super.key,
    required this.child,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;
    int columns;
    
    switch (deviceType) {
      case DeviceType.mobile:
        columns = mobileColumns ?? 1;
        break;
      case DeviceType.tablet:
        columns = tabletColumns ?? 2;
        break;
      case DeviceType.desktop:
        columns = desktopColumns ?? 3;
        break;
      case DeviceType.largeDesktop:
        columns = desktopColumns ?? 3;
        break;
    }

    if (columns == 1) {
      return child;
    }

    return Column(
      children: _splitChildren(context, columns),
    );
  }

  List<Widget> _splitChildren(BuildContext context, int columns) {
    final children = <Widget>[];
    final childWidgets = (child as Column).children;
    
    for (int i = 0; i < childWidgets.length; i += columns) {
      final rowChildren = <Widget>[];
      
      for (int j = 0; j < columns && (i + j) < childWidgets.length; j++) {
        rowChildren.add(
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: j < columns - 1 ? context.responsiveSpacing(mobile: 8, tablet: 12, desktop: 16) : 0,
              ),
              child: childWidgets[i + j],
            ),
          ),
        );
      }
      
      children.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      );
      
      if (i + columns < childWidgets.length) {
        children.add(
          SizedBox(height: context.responsiveSpacing(mobile: 16, tablet: 20, desktop: 24)),
        );
      }
    }
    
    return children;
  }
}

/// Widget para cards responsivos
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final Color? color;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? (context.isMobile ? 2 : 4),
      color: color,
      child: Padding(
        padding: padding ?? context.responsivePadding,
        child: child,
      ),
    );
  }
}

/// Widget para botões responsivos
class ResponsiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isFullWidth;

  const ResponsiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );

    if (isFullWidth || context.isMobile) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// Widget para texto responsivo
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style?.copyWith(
        fontSize: style?.fontSize != null 
            ? context.responsiveFontSize(
                mobile: style!.fontSize!,
                tablet: style!.fontSize! * 1.1,
                desktop: style!.fontSize! * 1.2,
                largeDesktop: style!.fontSize! * 1.3,
              )
            : null,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
