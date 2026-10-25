import 'package:e_smart/core/copy/app_copy.dart';
import 'package:e_smart/core/network/json_readers.dart';

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.city,
    required this.details,
    this.phone,
    this.recipientName,
  });

  final String id;
  final String label;
  final String city;
  final String details;
  final String? phone;
  final String? recipientName;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: readRequiredString(json['id'], 'id'),
      label: readOptionalString(json['label']) ?? AppCopy.addressFallbackLabel,
      city: readOptionalString(json['city']) ?? '',
      details: readOptionalString(json['details']) ?? '',
      phone: readOptionalString(json['phone']),
      recipientName: readOptionalString(json['recipientName']),
    );
  }
}
