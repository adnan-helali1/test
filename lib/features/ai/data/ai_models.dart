import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/json_readers.dart';
import 'package:e_smart/features/products/data/product.dart';

class AiStatus {
  const AiStatus({required this.available, required this.reason});

  final bool available;
  final String? reason;

  factory AiStatus.fromJson(Map<String, dynamic> json) {
    return AiStatus(
      available: readBool(json['available']),
      reason: readOptionalString(json['reason']),
    );
  }
}

class AiChatTurn {
  const AiChatTurn({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, String> toJson() => {'role': role, 'content': content};
}

class AiSearchResult {
  const AiSearchResult({
    required this.answer,
    required this.items,
    required this.total,
    required this.catalogTruncated,
    required this.catalogProductsConsidered,
  });

  final String answer;
  final List<Product> items;
  final int total;
  final bool catalogTruncated;
  final int catalogProductsConsidered;

  factory AiSearchResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <Product>[];
    if (rawItems is List) {
      for (final entry in rawItems) {
        final map = asStringKeyMap(entry);
        if (map != null) items.add(Product.fromJson(map));
      }
    }
    return AiSearchResult(
      answer: readOptionalString(json['answer']) ?? '',
      items: items,
      total: readOptionalInt(json['total']) ?? items.length,
      catalogTruncated: readBool(json['catalogTruncated']),
      catalogProductsConsidered:
          readOptionalInt(json['catalogProductsConsidered']) ?? 0,
    );
  }
}
