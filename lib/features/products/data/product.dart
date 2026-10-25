import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/json_readers.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.gallery,
    required this.priceMinor,
    required this.currency,
    required this.brand,
    required this.categorySlug,
    required this.stockQuantity,
    required this.averageRating,
    required this.reviewCount,
    required this.featured,
    required this.sku,
    required this.salePriceMinor,
    required this.basePriceMinor,
  });

  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<String> gallery;
  final int priceMinor;
  final String currency;
  final String brand;
  final String? categorySlug;
  final int stockQuantity;
  final double? averageRating;
  final int? reviewCount;
  final bool featured;
  final String? sku;
  final int? salePriceMinor;
  final int? basePriceMinor;

  bool get inStock => stockQuantity > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    final translations = asStringKeyMap(json['translations']);
    final attributes = asStringKeyMap(json['attributes']);
    final category = asStringKeyMap(json['category']);
    final imageUrl = readOptionalString(attributes?['imageUrl']);
    final seen = <String>{};
    final gallery = <String>[];
    void addImage(String? url) {
      if (url == null || !seen.add(url)) return;
      gallery.add(url);
    }

    addImage(imageUrl);
    for (final key in const [
      'angleFront',
      'angleRight',
      'angleBack',
      'angleLeft',
    ]) {
      addImage(readOptionalString(attributes?[key]));
    }
    return Product(
      id: readRequiredString(json['id'], 'id'),
      name: localizedField(translations, 'name'),
      description: localizedField(translations, 'description'),
      imageUrl: imageUrl,
      gallery: gallery,
      priceMinor: readRequiredInt(json['priceMinor'], 'priceMinor'),
      currency: readOptionalString(json['currency']) ?? '',
      brand: readOptionalString(json['brand']) ?? '',
      categorySlug: readOptionalString(category?['slug']),
      stockQuantity: readOptionalInt(json['stockQuantity']) ?? 0,
      averageRating: readOptionalDouble(json['averageRating']),
      reviewCount: readOptionalInt(json['reviewCount']),
      featured: readBool(json['featured']),
      sku: readOptionalString(json['sku']),
      salePriceMinor: readOptionalInt(json['salePriceMinor']),
      basePriceMinor: readOptionalInt(json['basePriceMinor']),
    );
  }
}

class CatalogPageData {
  const CatalogPageData({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    this.loadingMore = false,
  });

  final List<Product> items;
  final int page;
  final int limit;
  final int total;
  final bool loadingMore;

  bool get hasMore => page * limit < total;

  CatalogPageData copyWith({
    List<Product>? items,
    int? page,
    int? limit,
    int? total,
    bool? loadingMore,
  }) {
    return CatalogPageData(
      items: items ?? this.items,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  factory CatalogPageData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <Product>[];
    if (rawItems is List) {
      for (final entry in rawItems) {
        final map = asStringKeyMap(entry);
        if (map != null) items.add(Product.fromJson(map));
      }
    }
    return CatalogPageData(
      items: items,
      page: readOptionalInt(json['page']) ?? 1,
      limit: readOptionalInt(json['limit']) ?? items.length,
      total: readOptionalInt(json['total']) ?? items.length,
    );
  }
}

const catalogPageSize = 10;
