import 'package:equatable/equatable.dart';

enum SortOption {
  relevance,
  newest,
  popularity,
  rating,
  priceLowToHigh,
  priceHighToLow
}

extension SortOptionExt on SortOption {
  String? get apiValue {
    switch (this) {
      case SortOption.relevance:
        return null;
      case SortOption.newest:
        return 'newest';
      case SortOption.popularity:
        return 'popular';
      case SortOption.rating:
        return 'rating';
      case SortOption.priceLowToHigh:
        return 'price_asc';
      case SortOption.priceHighToLow:
        return 'price_desc';
    }
  }
}

class SearchFilterState extends Equatable {
  final String? categoryId;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final String? unit;
  final bool? inStock;
  final double? minRating;
  final int? maxMoq;
  final bool? hasCertificate;
  final bool? hasDelivery;
  final bool? hasDiscount;
  final SortOption sortOption;

  const SearchFilterState({
    this.categoryId,
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.unit,
    this.inStock,
    this.minRating,
    this.maxMoq,
    this.hasCertificate,
    this.hasDelivery,
    this.hasDiscount,
    this.sortOption = SortOption.relevance,
  });

  SearchFilterState copyWith({
    String? categoryId,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String? unit,
    bool? inStock,
    double? minRating,
    int? maxMoq,
    bool? hasCertificate,
    bool? hasDelivery,
    bool? hasDiscount,
    SortOption? sortOption,
  }) {
    return SearchFilterState(
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      unit: unit ?? this.unit,
      inStock: inStock ?? this.inStock,
      minRating: minRating ?? this.minRating,
      maxMoq: maxMoq ?? this.maxMoq,
      hasCertificate: hasCertificate ?? this.hasCertificate,
      hasDelivery: hasDelivery ?? this.hasDelivery,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      if (categoryId != null) 'category_id': categoryId,
      if (brand != null) 'brand': brand,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (unit != null) 'unit': unit,
      if (inStock != null && inStock!) 'in_stock_only': true,
      if (minRating != null) 'min_rating': minRating,
      if (maxMoq != null) 'max_moq': maxMoq,
      if (hasCertificate != null && hasCertificate!) 'has_certificate': true,
      if (hasDelivery != null && hasDelivery!) 'has_delivery': true,
      if (hasDiscount != null && hasDiscount!) 'has_discount': true,
      if (sortOption.apiValue != null) 'sort_by': sortOption.apiValue,
    };
  }

  @override
  List<Object?> get props => [
        categoryId,
        brand,
        minPrice,
        maxPrice,
        unit,
        inStock,
        minRating,
        maxMoq,
        hasCertificate,
        hasDelivery,
        hasDiscount,
        sortOption,
      ];
}
