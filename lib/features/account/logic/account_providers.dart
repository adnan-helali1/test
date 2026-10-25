import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/storage/token_store.dart';
import 'package:e_smart/features/account/data/address.dart';
import 'package:e_smart/features/account/data/address_repository.dart';
import 'package:e_smart/features/account/data/order.dart';
import 'package:e_smart/features/account/data/order_repository.dart';
import 'package:e_smart/features/account/data/support_repository.dart';
import 'package:e_smart/features/wishlist/logic/wishlist_controller.dart';

final accountOrdersProvider =
    FutureProvider.autoDispose<List<StoreOrder>>((ref) async {
  if (!ref.watch(tokenProvider).isAuthenticated) return const [];
  return ref.watch(orderRepositoryProvider).list();
});

final accountAddressesProvider =
    FutureProvider.autoDispose<List<Address>>((ref) async {
  if (!ref.watch(tokenProvider).isAuthenticated) return const [];
  return ref.watch(addressRepositoryProvider).list();
});

final accountChatsProvider =
    FutureProvider.autoDispose<List<SupportConversation>>((ref) async {
  if (!ref.watch(tokenProvider).isAuthenticated) return const [];
  return ref.watch(supportRepositoryProvider).list();
});

final accountOverviewCountsProvider =
    FutureProvider.autoDispose<({int orders, int wishlist, int addresses, int chats})>(
  (ref) async {
    if (!ref.watch(tokenProvider).isAuthenticated) {
      return (orders: 0, wishlist: 0, addresses: 0, chats: 0);
    }
    final orders = await ref.watch(accountOrdersProvider.future);
    final wishlist = await ref.watch(wishlistIdsProvider.future);
    final addresses = await ref.watch(accountAddressesProvider.future);
    final chats = await ref.watch(accountChatsProvider.future);
    return (
      orders: orders.length,
      wishlist: wishlist.length,
      addresses: addresses.length,
      chats: chats.length,
    );
  },
);
