/// Name and description fallback: Arabic, then English, then Turkish.
String localizedField(Map<String, dynamic>? translations, String field) {
  if (translations == null) return '';
  for (final code in const ['ar', 'en', 'tr']) {
    final block = translations[code];
    if (block is Map) {
      final value = block[field];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  }
  return '';
}

Map<String, dynamic>? asStringKeyMap(dynamic raw) {
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}
