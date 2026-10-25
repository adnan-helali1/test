import 'package:e_smart/core/format/localized_text.dart';

int? readOptionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Accepts either a bare JSON array or `{ "items": [] }`.
List<Map<String, dynamic>> readListOrItems(dynamic data) {
  final items = <Map<String, dynamic>>[];
  final raw = data is List
      ? data
      : (asStringKeyMap(data)?['items'] is List
            ? asStringKeyMap(data)!['items'] as List
            : const []);
  for (final entry in raw) {
    final map = asStringKeyMap(entry);
    if (map != null) items.add(map);
  }
  return items;
}

bool looksLikeUuid(String? value) {
  if (value == null) return false;
  final t = value.trim();
  if (t.length < 32) return false;
  final uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  return uuid.hasMatch(t);
}

int readRequiredInt(dynamic value, String field) {
  final parsed = readOptionalInt(value);
  if (parsed == null) {
    throw FormatException('Missing $field');
  }
  return parsed;
}

double? readOptionalDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String readRequiredString(dynamic value, String field) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw FormatException('Missing $field');
}

String? readOptionalString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

bool readBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  return fallback;
}
