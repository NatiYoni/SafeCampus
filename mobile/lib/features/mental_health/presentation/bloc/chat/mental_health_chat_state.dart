import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatMessage extends Equatable {
  final String content;
  final bool isUser;

  const ChatMessage({required this.content, required this.isUser});

  @override
  List<Object> get props => [content, isUser];
}

class MentalHealthChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final String errorMessage;

  const MentalHealthChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage = '',
  });

  MentalHealthChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? errorMessage,
  }) {
    return MentalHealthChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, messages, errorMessage];
}
