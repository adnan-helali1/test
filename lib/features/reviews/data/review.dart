import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/json_readers.dart';

class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.displayName,
    required this.text,
    required this.createdAt,
    required this.verifiedPurchase,
  });

  final String id;
  final int rating;
  final String? displayName;
  final String? text;
  final String? createdAt;
  final bool verifiedPurchase;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: readRequiredString(json['id'], 'id'),
      rating: readOptionalInt(json['rating']) ?? 0,
      displayName: readOptionalString(json['displayName']),
      text: readOptionalString(json['text']),
      createdAt: readOptionalString(json['createdAt']),
      verifiedPurchase: readBool(json['verifiedPurchase']),
    );
  }
}

class ReviewPageData {
  const ReviewPageData({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.averageRating,
    this.loadingMore = false,
  });

  final List<Review> items;
  final int page;
  final int limit;
  final int total;
  final double? averageRating;
  final bool loadingMore;

  bool get hasMore => page * limit < total;

  ReviewPageData copyWith({
    List<Review>? items,
    int? page,
    int? limit,
    int? total,
    double? averageRating,
    bool? loadingMore,
  }) {
    return ReviewPageData(
      items: items ?? this.items,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      averageRating: averageRating ?? this.averageRating,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  factory ReviewPageData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <Review>[];
    if (rawItems is List) {
      for (final entry in rawItems) {
        final map = asStringKeyMap(entry);
        if (map != null) items.add(Review.fromJson(map));
      }
    }
    return ReviewPageData(
      items: items,
      page: readOptionalInt(json['page']) ?? 1,
      limit: readOptionalInt(json['limit']) ?? items.length,
      total: readOptionalInt(json['total']) ?? items.length,
      averageRating: readOptionalDouble(json['averageRating']),
    );
  }
}
