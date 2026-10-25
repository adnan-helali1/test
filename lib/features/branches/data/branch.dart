import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/json_readers.dart';

class Branch {
  const Branch({
    required this.id,
    required this.code,
    required this.active,
    required this.name,
    required this.phone,
  });

  final String id;
  final String code;
  final bool active;
  final String name;
  final String? phone;

  factory Branch.fromJson(Map<String, dynamic> json) {
    final code = readOptionalString(json['code']) ?? '';
    return Branch(
      id: readRequiredString(json['id'], 'id'),
      code: code,
      active: readBool(json['active']),
      name: _branchName(json['translations'], code),
      phone: readOptionalString(json['phone']),
    );
  }
}

/// Branch names follow the contract: Arabic, then English, then the code.
String _branchName(dynamic translations, String code) {
  final map = asStringKeyMap(translations);
  for (final language in const ['ar', 'en']) {
    final block = asStringKeyMap(map?[language]);
    final name = readOptionalString(block?['name']);
    if (name != null) return name;
  }
  return code;
}
