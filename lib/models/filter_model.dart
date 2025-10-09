enum TransactionType { sale, rent, daily }

class PropertyFilters {
  final double? minPrice;
  final double? maxPrice;
  final TransactionType? transactionType;
  final double? maxCondominium;
  final double? maxIptu;
  final bool showOnlyWithPrice;
  final bool acceptProposal;
  final bool hasFinancing;
  final List<String> priceRanges;

  const PropertyFilters({
    this.minPrice,
    this.maxPrice,
    this.transactionType,
    this.maxCondominium,
    this.maxIptu,
    this.showOnlyWithPrice = false,
    this.acceptProposal = false,
    this.hasFinancing = false,
    this.priceRanges = const [],
  });

  PropertyFilters copyWith({
    double? minPrice,
    double? maxPrice,
    TransactionType? transactionType,
    double? maxCondominium,
    double? maxIptu,
    bool? showOnlyWithPrice,
    bool? acceptProposal,
    bool? hasFinancing,
    List<String>? priceRanges,
  }) {
    return PropertyFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      transactionType: transactionType ?? this.transactionType,
      maxCondominium: maxCondominium ?? this.maxCondominium,
      maxIptu: maxIptu ?? this.maxIptu,
      showOnlyWithPrice: showOnlyWithPrice ?? this.showOnlyWithPrice,
      acceptProposal: acceptProposal ?? this.acceptProposal,
      hasFinancing: hasFinancing ?? this.hasFinancing,
      priceRanges: priceRanges ?? this.priceRanges,
    );
  }

  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        transactionType != null ||
        maxCondominium != null ||
        maxIptu != null ||
        showOnlyWithPrice ||
        acceptProposal ||
        hasFinancing ||
        priceRanges.isNotEmpty;
  }

  PropertyFilters clear() {
    return const PropertyFilters();
  }
}

class PriceRange {
  final String label;
  final double? minPrice;
  final double? maxPrice;

  const PriceRange({
    required this.label,
    this.minPrice,
    this.maxPrice,
  });

  static const List<PriceRange> predefinedRanges = [
    PriceRange(label: 'Até R\$ 100.000', maxPrice: 100000),
    PriceRange(label: 'R\$ 100.000 – R\$ 300.000', minPrice: 100000, maxPrice: 300000),
    PriceRange(label: 'R\$ 300.000 – R\$ 500.000', minPrice: 300000, maxPrice: 500000),
    PriceRange(label: 'R\$ 500.000 – R\$ 1.000.000', minPrice: 500000, maxPrice: 1000000),
    PriceRange(label: 'Acima de R\$ 1.000.000', minPrice: 1000000),
  ];
}
