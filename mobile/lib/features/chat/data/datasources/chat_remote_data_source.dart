import 'package:dio/dio.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<void> sendMessage(MessageModel message);
  Future<List<MessageModel>> getMessages(String reportId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio client;

  ChatRemoteDataSourceImpl({required this.client});

  @override
  Future<void> sendMessage(MessageModel message) async {
    final response = await client.post(
      '/chats/messages',
      data: message.toJson(),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String reportId) async {
    final response = await client.get(
      '/chats/$reportId/messages',
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }
}

