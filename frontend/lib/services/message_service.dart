import 'package:dio/dio.dart';
import '../utils/constants.dart';

class MessageService {
  final Dio _dio = Dio();

  // Get all conversations
  Future<Response> getConversations({required String token}) async {
    try {
      final response = await _dio.get(
        '$apiUrl/messages/conversations',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get messages for a conversation
  Future<Response> getMessages({
    required String token,
    required String otherUserId,
  }) async {
    try {
      final response = await _dio.get(
        '$apiUrl/messages/$otherUserId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Send a message
  Future<Response> sendMessage({
    required String token,
    required String receiverId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '$apiUrl/messages/send',
        data: {'receiverId': receiverId, 'content': content},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Mark messages as read
  Future<Response> markAsRead({
    required String token,
    required String otherUserId,
  }) async {
    try {
      final response = await _dio.put(
        '$apiUrl/messages/$otherUserId/read',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
