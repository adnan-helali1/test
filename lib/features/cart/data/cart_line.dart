class CartLine {
  const CartLine({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.priceMinor,
    required this.currency,
    required this.quantity,
  });

  final String productId;
  final String name;
  final String? imageUrl;
  final int priceMinor;
  final String currency;
  final int quantity;

  int get lineTotalMinor => priceMinor * quantity;

  CartLine copyWith({int? quantity}) {
    return CartLine(
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      priceMinor: priceMinor,
      currency: currency,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// Fixed cart-screen shipping display (not from API).
const cartShippingDisplaySar = 25;
