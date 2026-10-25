import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/json_readers.dart';

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPriceMinor,
  });

  final String productId;
  final String productName;
  final int quantity;
  final int unitPriceMinor;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: readOptionalString(json['productId']) ?? '',
      productName: readOptionalString(json['productName']) ?? '',
      quantity: readOptionalInt(json['quantity']) ?? 0,
      unitPriceMinor: readOptionalInt(json['unitPriceMinor']) ?? 0,
    );
  }
}

class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.currency,
    required this.totalMinor,
    required this.discountMinor,
    required this.shippingMinor,
    required this.createdAt,
    required this.customerName,
    required this.items,
  });

  final String id;
  final String? orderNumber;
  final String status;
  final String? paymentMethod;
  final String currency;
  final int totalMinor;
  final int discountMinor;
  final int shippingMinor;
  final String? createdAt;
  final String customerName;
  final List<OrderItem> items;

  String get statusLabel => orderStatusLabel(status);

  String? get dateLabel {
    final raw = createdAt;
    if (raw == null || raw.length < 10) return null;
    return raw.substring(0, 10);
  }

  factory StoreOrder.fromJson(Map<String, dynamic> json) {
    final customer = asStringKeyMap(json['customer']);
    final shipping = asStringKeyMap(json['shippingAddress']);
    final name = _customerName(
      readOptionalString(customer?['fullName']),
      readOptionalString(shipping?['recipientName']),
    );
    final rawItems = json['items'];
    final items = <OrderItem>[];
    if (rawItems is List) {
      for (final entry in rawItems) {
        final map = asStringKeyMap(entry);
        if (map != null) items.add(OrderItem.fromJson(map));
      }
    }
    return StoreOrder(
      id: readRequiredString(json['id'], 'id'),
      orderNumber: readOptionalString(json['orderNumber']),
      status: readOptionalString(json['status']) ?? '',
      paymentMethod: readOptionalString(json['paymentMethod']),
      currency: readOptionalString(json['currency']) ?? '',
      totalMinor: readOptionalInt(json['totalMinor']) ?? 0,
      discountMinor: readOptionalInt(json['discountMinor']) ?? 0,
      shippingMinor: readOptionalInt(json['shippingMinor']) ?? 0,
      createdAt: readOptionalString(json['createdAt']),
      customerName: name,
      items: items,
    );
  }
}

String orderStatusLabel(String status) {
  return switch (status) {
    'new' => 'جديد',
    'confirmed' => 'مؤكد',
    'processing' => 'قيد التجهيز',
    'shipped' => 'تم الشحن',
    'delivered' => 'تم التسليم',
    'cancelled' => 'ملغي',
    _ => status,
  };
}

String _customerName(String? fullName, String? recipient) {
  for (final candidate in [fullName, recipient]) {
    if (candidate == null || candidate.isEmpty) continue;
    if (looksLikeUuid(candidate)) continue;
    return candidate;
  }
  return AppCopy.customerFallback;
}
