// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return _ProductModel.fromJson(json);
}

/// @nodoc
mixin _$ProductModel {
  String get id => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  LocalizedString get name => throw _privateConstructorUsedError;
  LocalizedString get description => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;
  List<String>? get videos => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String? get subcategoryId => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double? get oldPrice => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  int? get moq => throw _privateConstructorUsedError;
  int? get stock => throw _privateConstructorUsedError;
  String? get stockStatus => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  int? get reviewCount => throw _privateConstructorUsedError;
  double? get discount => throw _privateConstructorUsedError;
  Map<String, String>? get specifications => throw _privateConstructorUsedError;
  List<String>? get certificates => throw _privateConstructorUsedError;
  String? get deliveryInformation => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
          ProductModel value, $Res Function(ProductModel) then) =
      _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call(
      {String id,
      String? sku,
      LocalizedString name,
      LocalizedString description,
      List<String>? images,
      List<String>? videos,
      String? brand,
      String categoryId,
      String? subcategoryId,
      double price,
      double? oldPrice,
      String currency,
      String unit,
      int? moq,
      int? stock,
      String? stockStatus,
      double? rating,
      int? reviewCount,
      double? discount,
      Map<String, String>? specifications,
      List<String>? certificates,
      String? deliveryInformation,
      String? location,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sku = freezed,
    Object? name = null,
    Object? description = null,
    Object? images = freezed,
    Object? videos = freezed,
    Object? brand = freezed,
    Object? categoryId = null,
    Object? subcategoryId = freezed,
    Object? price = null,
    Object? oldPrice = freezed,
    Object? currency = null,
    Object? unit = null,
    Object? moq = freezed,
    Object? stock = freezed,
    Object? stockStatus = freezed,
    Object? rating = freezed,
    Object? reviewCount = freezed,
    Object? discount = freezed,
    Object? specifications = freezed,
    Object? certificates = freezed,
    Object? deliveryInformation = freezed,
    Object? location = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as LocalizedString,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as LocalizedString,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      videos: freezed == videos
          ? _value.videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      subcategoryId: freezed == subcategoryId
          ? _value.subcategoryId
          : subcategoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      oldPrice: freezed == oldPrice
          ? _value.oldPrice
          : oldPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      moq: freezed == moq
          ? _value.moq
          : moq // ignore: cast_nullable_to_non_nullable
              as int?,
      stock: freezed == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int?,
      stockStatus: freezed == stockStatus
          ? _value.stockStatus
          : stockStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      reviewCount: freezed == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int?,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double?,
      specifications: freezed == specifications
          ? _value.specifications
          : specifications // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      certificates: freezed == certificates
          ? _value.certificates
          : certificates // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      deliveryInformation: freezed == deliveryInformation
          ? _value.deliveryInformation
          : deliveryInformation // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
          _$ProductModelImpl value, $Res Function(_$ProductModelImpl) then) =
      __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? sku,
      LocalizedString name,
      LocalizedString description,
      List<String>? images,
      List<String>? videos,
      String? brand,
      String categoryId,
      String? subcategoryId,
      double price,
      double? oldPrice,
      String currency,
      String unit,
      int? moq,
      int? stock,
      String? stockStatus,
      double? rating,
      int? reviewCount,
      double? discount,
      Map<String, String>? specifications,
      List<String>? certificates,
      String? deliveryInformation,
      String? location,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
      _$ProductModelImpl _value, $Res Function(_$ProductModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sku = freezed,
    Object? name = null,
    Object? description = null,
    Object? images = freezed,
    Object? videos = freezed,
    Object? brand = freezed,
    Object? categoryId = null,
    Object? subcategoryId = freezed,
    Object? price = null,
    Object? oldPrice = freezed,
    Object? currency = null,
    Object? unit = null,
    Object? moq = freezed,
    Object? stock = freezed,
    Object? stockStatus = freezed,
    Object? rating = freezed,
    Object? reviewCount = freezed,
    Object? discount = freezed,
    Object? specifications = freezed,
    Object? certificates = freezed,
    Object? deliveryInformation = freezed,
    Object? location = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ProductModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as LocalizedString,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as LocalizedString,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      videos: freezed == videos
          ? _value._videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      subcategoryId: freezed == subcategoryId
          ? _value.subcategoryId
          : subcategoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      oldPrice: freezed == oldPrice
          ? _value.oldPrice
          : oldPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      moq: freezed == moq
          ? _value.moq
          : moq // ignore: cast_nullable_to_non_nullable
              as int?,
      stock: freezed == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int?,
      stockStatus: freezed == stockStatus
          ? _value.stockStatus
          : stockStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      reviewCount: freezed == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int?,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double?,
      specifications: freezed == specifications
          ? _value._specifications
          : specifications // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      certificates: freezed == certificates
          ? _value._certificates
          : certificates // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      deliveryInformation: freezed == deliveryInformation
          ? _value.deliveryInformation
          : deliveryInformation // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductModelImpl extends _ProductModel {
  const _$ProductModelImpl(
      {required this.id,
      this.sku,
      required this.name,
      required this.description,
      final List<String>? images,
      final List<String>? videos,
      this.brand,
      required this.categoryId,
      this.subcategoryId,
      required this.price,
      this.oldPrice,
      required this.currency,
      required this.unit,
      this.moq,
      this.stock,
      this.stockStatus,
      this.rating,
      this.reviewCount,
      this.discount,
      final Map<String, String>? specifications,
      final List<String>? certificates,
      this.deliveryInformation,
      this.location,
      this.createdAt,
      this.updatedAt})
      : _images = images,
        _videos = videos,
        _specifications = specifications,
        _certificates = certificates,
        super._();

  factory _$ProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductModelImplFromJson(json);

  @override
  final String id;
  @override
  final String? sku;
  @override
  final LocalizedString name;
  @override
  final LocalizedString description;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _videos;
  @override
  List<String>? get videos {
    final value = _videos;
    if (value == null) return null;
    if (_videos is EqualUnmodifiableListView) return _videos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? brand;
  @override
  final String categoryId;
  @override
  final String? subcategoryId;
  @override
  final double price;
  @override
  final double? oldPrice;
  @override
  final String currency;
  @override
  final String unit;
  @override
  final int? moq;
  @override
  final int? stock;
  @override
  final String? stockStatus;
  @override
  final double? rating;
  @override
  final int? reviewCount;
  @override
  final double? discount;
  final Map<String, String>? _specifications;
  @override
  Map<String, String>? get specifications {
    final value = _specifications;
    if (value == null) return null;
    if (_specifications is EqualUnmodifiableMapView) return _specifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _certificates;
  @override
  List<String>? get certificates {
    final value = _certificates;
    if (value == null) return null;
    if (_certificates is EqualUnmodifiableListView) return _certificates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? deliveryInformation;
  @override
  final String? location;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ProductModel(id: $id, sku: $sku, name: $name, description: $description, images: $images, videos: $videos, brand: $brand, categoryId: $categoryId, subcategoryId: $subcategoryId, price: $price, oldPrice: $oldPrice, currency: $currency, unit: $unit, moq: $moq, stock: $stock, stockStatus: $stockStatus, rating: $rating, reviewCount: $reviewCount, discount: $discount, specifications: $specifications, certificates: $certificates, deliveryInformation: $deliveryInformation, location: $location, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._videos, _videos) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.subcategoryId, subcategoryId) ||
                other.subcategoryId == subcategoryId) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.oldPrice, oldPrice) ||
                other.oldPrice == oldPrice) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.moq, moq) || other.moq == moq) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.stockStatus, stockStatus) ||
                other.stockStatus == stockStatus) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            const DeepCollectionEquality()
                .equals(other._specifications, _specifications) &&
            const DeepCollectionEquality()
                .equals(other._certificates, _certificates) &&
            (identical(other.deliveryInformation, deliveryInformation) ||
                other.deliveryInformation == deliveryInformation) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        sku,
        name,
        description,
        const DeepCollectionEquality().hash(_images),
        const DeepCollectionEquality().hash(_videos),
        brand,
        categoryId,
        subcategoryId,
        price,
        oldPrice,
        currency,
        unit,
        moq,
        stock,
        stockStatus,
        rating,
        reviewCount,
        discount,
        const DeepCollectionEquality().hash(_specifications),
        const DeepCollectionEquality().hash(_certificates),
        deliveryInformation,
        location,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductModelImplToJson(
      this,
    );
  }
}

abstract class _ProductModel extends ProductModel {
  const factory _ProductModel(
      {required final String id,
      final String? sku,
      required final LocalizedString name,
      required final LocalizedString description,
      final List<String>? images,
      final List<String>? videos,
      final String? brand,
      required final String categoryId,
      final String? subcategoryId,
      required final double price,
      final double? oldPrice,
      required final String currency,
      required final String unit,
      final int? moq,
      final int? stock,
      final String? stockStatus,
      final double? rating,
      final int? reviewCount,
      final double? discount,
      final Map<String, String>? specifications,
      final List<String>? certificates,
      final String? deliveryInformation,
      final String? location,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$ProductModelImpl;
  const _ProductModel._() : super._();

  factory _ProductModel.fromJson(Map<String, dynamic> json) =
      _$ProductModelImpl.fromJson;

  @override
  String get id;
  @override
  String? get sku;
  @override
  LocalizedString get name;
  @override
  LocalizedString get description;
  @override
  List<String>? get images;
  @override
  List<String>? get videos;
  @override
  String? get brand;
  @override
  String get categoryId;
  @override
  String? get subcategoryId;
  @override
  double get price;
  @override
  double? get oldPrice;
  @override
  String get currency;
  @override
  String get unit;
  @override
  int? get moq;
  @override
  int? get stock;
  @override
  String? get stockStatus;
  @override
  double? get rating;
  @override
  int? get reviewCount;
  @override
  double? get discount;
  @override
  Map<String, String>? get specifications;
  @override
  List<String>? get certificates;
  @override
  String? get deliveryInformation;
  @override
  String? get location;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
