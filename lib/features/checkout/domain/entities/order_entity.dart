import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';

class OrderEntity {
  final String id;
  final String orderNumber;
  final String invoiceNumber;
  final String status;
  final String paymentStatus;
  final String deliveryStatus;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double tax;
  final double total;
  final DateTime createdAt;
  final List<CartItemEntity> items;
  final String deliveryAddress;
  final String paymentMethod;
  final String deliveryMethod;
  final String trackingNumber;
  final String customerNotes;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.invoiceNumber,
    required this.status,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.tax,
    required this.total,
    required this.createdAt,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.deliveryMethod,
    required this.trackingNumber,
    required this.customerNotes,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      deliveryStatus: json['deliveryStatus'] as String? ?? 'Pending',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map<CartItemEntity>(
                (e) => CartItemEntity.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      deliveryMethod: json['deliveryMethod'] as String? ?? '',
      trackingNumber: json['trackingNumber'] as String? ?? '',
      customerNotes: json['customerNotes'] as String? ?? '',
    );
  }
}
