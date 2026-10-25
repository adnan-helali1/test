const mediaOrigin = 'https://e-smart.nmo.marketing';

/// Absolute URLs stay unchanged. Other paths are prefixed with the host origin.
String? resolveMediaUrl(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return trimmed;
  }
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$mediaOrigin$path';
}
