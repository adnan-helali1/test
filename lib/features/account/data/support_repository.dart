import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/core/format/localized_text.dart';
import 'package:e_smart/core/network/app_failure.dart';
import 'package:e_smart/core/network/dio_client.dart';
import 'package:e_smart/core/network/json_readers.dart';

class SupportMessage {
  const SupportMessage({this.id, this.body, this.createdAt, this.fromStaff});

  final String? id;
  final String? body;
  final String? createdAt;
  final bool? fromStaff;

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: readOptionalString(json['id']),
      body: readOptionalString(json['body'] ?? json['message']),
      createdAt: readOptionalString(json['createdAt']),
      fromStaff: json['fromStaff'] is bool ? json['fromStaff'] as bool : null,
    );
  }
}

class SupportConversation {
  const SupportConversation({
    required this.id,
    this.subject,
    this.kind,
    this.messages = const [],
  });

  final String id;
  final String? subject;
  final String? kind;
  final List<SupportMessage> messages;

  factory SupportConversation.fromJson(Map<String, dynamic> json) {
    final raw = json['messages'];
    final messages = <SupportMessage>[];
    if (raw is List) {
      for (final entry in raw) {
        final map = asStringKeyMap(entry);
        if (map != null) messages.add(SupportMessage.fromJson(map));
      }
    }
    return SupportConversation(
      id: readRequiredString(json['id'], 'id'),
      subject: readOptionalString(json['subject']),
      kind: readOptionalString(json['kind']),
      messages: messages,
    );
  }
}

class SupportRepository {
  SupportRepository(this._dio);

  final Dio _dio;

  Future<List<SupportConversation>> list() async {
    try {
      final response = await _dio.get<dynamic>('/support/conversations');
      return [
        for (final map in readListOrItems(response.data))
          SupportConversation.fromJson(map),
      ];
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<SupportConversation> create({
    required String kind,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/support/conversations',
        data: {'kind': kind, 'subject': subject, 'message': message},
      );
      final map = asStringKeyMap(response.data);
      if (map == null) throw const ServerFailure();
      return SupportConversation.fromJson(map);
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<SupportConversation> getById(String id) async {
    try {
      final response = await _dio.get<dynamic>('/support/conversations/$id');
      final map = asStringKeyMap(response.data);
      if (map == null) throw const ServerFailure();
      return SupportConversation.fromJson(map);
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    try {
      await _dio.post<dynamic>(
        '/support/conversations/$conversationId/messages',
        data: {'body': body},
      );
    } on DioException catch (error) {
      throw mapDio(error);
    }
  }
}

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository(ref.watch(dioProvider));
});
