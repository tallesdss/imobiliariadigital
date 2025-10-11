import 'package:flutter/material.dart';

/// Sistema de breakpoints responsivos para a aplicação
class AppBreakpoints {
  // Breakpoints baseados no Material Design
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;

  /// Verifica se a tela é mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Verifica se a tela é tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  /// Verifica se a tela é desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  /// Verifica se a tela é large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Retorna o tipo de dispositivo atual
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobile) return DeviceType.mobile;
    if (width < tablet) return DeviceType.tablet;
    if (width < desktop) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// Retorna o número de colunas baseado no tamanho da tela
  static int getGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.largeDesktop:
        return 4;
    }
  }

  /// Retorna o espaçamento baseado no tamanho da tela
  static double getSpacing(BuildContext context, {
    double mobile = 16,
    double tablet = 20,
    double desktop = 24,
    double largeDesktop = 32,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.largeDesktop:
        return largeDesktop;
    }
  }

  /// Retorna o tamanho da sidebar baseado no dispositivo
  static double getSidebarWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 280;
      case DeviceType.tablet:
        return 320;
      case DeviceType.desktop:
        return 360;
      case DeviceType.largeDesktop:
        return 400;
    }
  }

  /// Retorna se a sidebar deve ser colapsável
  static bool shouldCollapseSidebar(BuildContext context) {
    return isMobile(context);
  }

  /// Retorna o padding baseado no dispositivo
  static EdgeInsets getPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(20);
      case DeviceType.desktop:
        return const EdgeInsets.all(24);
      case DeviceType.largeDesktop:
        return const EdgeInsets.all(32);
    }
  }

  /// Retorna o tamanho da fonte baseado no dispositivo
  static double getFontSize(BuildContext context, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
    double largeDesktop = 20,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.largeDesktop:
        return largeDesktop;
    }
  }
}

/// Tipos de dispositivo
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Extensão para facilitar o uso dos breakpoints
extension ResponsiveExtension on BuildContext {
  bool get isMobile => AppBreakpoints.isMobile(this);
  bool get isTablet => AppBreakpoints.isTablet(this);
  bool get isDesktop => AppBreakpoints.isDesktop(this);
  bool get isLargeDesktop => AppBreakpoints.isLargeDesktop(this);
  
  DeviceType get deviceType => AppBreakpoints.getDeviceType(this);
  
  int get gridColumns => AppBreakpoints.getGridColumns(this);
  
  double get sidebarWidth => AppBreakpoints.getSidebarWidth(this);
  
  bool get shouldCollapseSidebar => AppBreakpoints.shouldCollapseSidebar(this);
  
  EdgeInsets get responsivePadding => AppBreakpoints.getPadding(this);
  
  double responsiveFontSize({
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
    double largeDesktop = 20,
  }) => AppBreakpoints.getFontSize(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
    largeDesktop: largeDesktop,
  );
  
  double responsiveSpacing({
    double mobile = 16,
    double tablet = 20,
    double desktop = 24,
    double largeDesktop = 32,
  }) => AppBreakpoints.getSpacing(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
    largeDesktop: largeDesktop,
  );
}
