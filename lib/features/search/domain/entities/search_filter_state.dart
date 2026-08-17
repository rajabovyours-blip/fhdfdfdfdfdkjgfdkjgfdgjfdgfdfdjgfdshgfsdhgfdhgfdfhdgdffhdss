import 'package:equatable/equatable.dart';

enum SortOption {
  relevance,
  newest,
  popularity,
  rating,
  priceLowToHigh,
  priceHighToLow
}

class SearchFilterState extends Equatable {
  final String? categoryId;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final String? region;
  final String? district;
  final bool? inStock;
  final double? minRating;
  final bool? hasDiscount;
  final bool? isWholesale;
  final bool? isRetail;
  final SortOption sortOption;

  const SearchFilterState({
    this.categoryId,
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.region,
    this.district,
    this.inStock,
    this.minRating,
    this.hasDiscount,
    this.isWholesale,
    this.isRetail,
    this.sortOption = SortOption.relevance,
  });

  SearchFilterState copyWith({
    String? categoryId,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String? region,
    String? district,
    bool? inStock,
    double? minRating,
    bool? hasDiscount,
    bool? isWholesale,
    bool? isRetail,
    SortOption? sortOption,
  }) {
    return SearchFilterState(
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      region: region ?? this.region,
      district: district ?? this.district,
      inStock: inStock ?? this.inStock,
      minRating: minRating ?? this.minRating,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      isWholesale: isWholesale ?? this.isWholesale,
      isRetail: isRetail ?? this.isRetail,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      if (categoryId != null) 'category_id': categoryId,
      if (brand != null) 'brand': brand,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (region != null) 'region': region,
      if (district != null) 'district': district,
      if (inStock != null) 'in_stock': inStock,
      if (minRating != null) 'min_rating': minRating,
      if (hasDiscount != null) 'has_discount': hasDiscount,
      if (isWholesale != null) 'is_wholesale': isWholesale,
      if (isRetail != null) 'is_retail': isRetail,
      'sort': sortOption.name,
    };
  }

  @override
  List<Object?> get props => [
        categoryId,
        brand,
        minPrice,
        maxPrice,
        region,
        district,
        inStock,
        minRating,
        hasDiscount,
        isWholesale,
        isRetail,
        sortOption,
      ];
}
