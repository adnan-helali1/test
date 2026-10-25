import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:e_smart/core/storage/token_store.dart';
import 'package:e_smart/core/widgets/store_shell.dart';
import 'package:e_smart/features/account/ui/account_pages.dart';
import 'package:e_smart/features/ai/ui/search_page.dart';
import 'package:e_smart/features/auth/ui/auth_pages.dart';
import 'package:e_smart/features/branches/ui/branches_page.dart';
import 'package:e_smart/features/cart/ui/cart_page.dart';
import 'package:e_smart/features/cart/ui/checkout_page.dart';
import 'package:e_smart/features/content/ui/static_page_view.dart';
import 'package:e_smart/features/products/ui/brands_page.dart';
import 'package:e_smart/features/products/ui/catalog_page.dart';
import 'package:e_smart/features/products/ui/product_details_page.dart';
import 'package:e_smart/features/wishlist/ui/wishlist_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(tokenProvider).isAuthenticated;
      final path = state.uri.path;
      final protected = path == '/checkout' ||
          (path.startsWith('/account') && path != '/account/authenticity');
      if (!signedIn && protected) {
        return '/login?from=${Uri.encodeQueryComponent(state.uri.toString())}';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => StoreShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const CatalogPage()),
          GoRoute(
            path: '/products',
            builder: (context, state) => const CatalogPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => ProductDetailsPage(
                  productId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/branches',
            builder: (context, state) => const BranchesPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => BranchDetailsPage(
                  branchId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/brands',
            builder: (context, state) => const BrandsPage(),
            routes: [
              GoRoute(
                path: 'view',
                builder: (context, state) => BrandProductsPage(
                  brand: state.uri.queryParameters['name'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => SearchPage(
              query: state.uri.queryParameters['q'] ?? '',
            ),
          ),
          GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
          GoRoute(
            path: '/checkout',
            builder: (context, state) => const CheckoutPage(),
          ),
          GoRoute(
            path: '/checkout/success',
            builder: (context, state) => CheckoutSuccessPage(
              orderNumber: state.uri.queryParameters['orderNumber'],
            ),
          ),
          GoRoute(
            path: '/wishlist',
            builder: (context, state) => const WishlistPage(),
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) => const AccountOverviewPage(),
          ),
          GoRoute(
            path: '/account/orders',
            builder: (context, state) => const AccountOrdersPage(),
          ),
          GoRoute(
            path: '/account/wishlist',
            builder: (context, state) => const AccountWishlistPage(),
          ),
          GoRoute(
            path: '/account/addresses',
            builder: (context, state) => const AccountAddressesPage(),
          ),
          GoRoute(
            path: '/account/chats',
            builder: (context, state) => const AccountChatsPage(),
          ),
          GoRoute(
            path: '/account/authenticity',
            builder: (context, state) => const AccountAuthenticityPage(),
          ),
          GoRoute(
            path: '/pages/:slug',
            builder: (context, state) => StaticPageView(
              slug: state.pathParameters['slug']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginPage(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordPage(
          token: state.uri.queryParameters['token'],
        ),
      ),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(tokenProvider, (_, _) => notifyListeners());
  }
}
