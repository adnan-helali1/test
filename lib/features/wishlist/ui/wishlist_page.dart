import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Header shortcut — account wishlist is the canonical screen.
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/account/wishlist');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
