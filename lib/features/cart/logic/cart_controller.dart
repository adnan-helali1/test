import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/features/cart/data/cart_line.dart';

class CartController extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() => const [];

  int get count => state.fold(0, (sum, line) => sum + line.quantity);

  int get subtotalMinor =>
      state.fold(0, (sum, line) => sum + line.lineTotalMinor);

  String get currency {
    for (final line in state) {
      if (line.currency.isNotEmpty) return line.currency;
    }
    return 'SAR';
  }

  void add({
    required String productId,
    required String name,
    required String? imageUrl,
    required int priceMinor,
    required String currency,
    int quantity = 1,
  }) {
    final qty = quantity.clamp(1, 100);
    final index = state.indexWhere((l) => l.productId == productId);
    if (index < 0) {
      state = [
        ...state,
        CartLine(
          productId: productId,
          name: name,
          imageUrl: imageUrl,
          priceMinor: priceMinor,
          currency: currency,
          quantity: qty,
        ),
      ];
      return;
    }
    final current = state[index];
    final next = (current.quantity + qty).clamp(1, 100);
    final copy = [...state];
    copy[index] = current.copyWith(quantity: next);
    state = copy;
  }

  void setQuantity(String productId, int quantity) {
    final qty = quantity.clamp(1, 100);
    state = [
      for (final line in state)
        if (line.productId == productId) line.copyWith(quantity: qty) else line,
    ];
  }

  void remove(String productId) {
    state = [for (final line in state) if (line.productId != productId) line];
  }

  void clear() => state = const [];
}

final cartProvider = NotifierProvider<CartController, List<CartLine>>(
  CartController.new,
);

final cartCountProvider = Provider<int>((ref) {
  final lines = ref.watch(cartProvider);
  return lines.fold(0, (sum, line) => sum + line.quantity);
});
