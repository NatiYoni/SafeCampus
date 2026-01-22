import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/send_chat_to_companion.dart';
import 'mental_health_chat_event.dart';
import 'mental_health_chat_state.dart';

class MentalHealthChatBloc extends Bloc<MentalHealthChatEvent, MentalHealthChatState> {
  final SendChatToCompanion sendChat;

  MentalHealthChatBloc({required this.sendChat}) : super(const MentalHealthChatState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ClearHistoryEvent>(_onClearHistory);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<MentalHealthChatState> emit) async {
    final currentMessages = List<ChatMessage>.from(state.messages);
    
    // Add User Message Optimistically
    currentMessages.add(ChatMessage(content: event.message, isUser: true));
    emit(state.copyWith(
      status: ChatStatus.loading,
      messages: currentMessages,
    ));

    // Prepare History for Backend (convert to Map)
    final history = state.messages.map((m) => {
      'role': m.isUser ? 'user' : 'model',
      'content': m.content,
    }).toList();

    final result = await sendChat(ChatParams(message: event.message, history: history));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: failure.message,
      )),
      (response) {
        final updatedMessages = List<ChatMessage>.from(state.messages); // Re-fetch in case state changed
        updatedMessages.add(ChatMessage(content: response, isUser: false));
        emit(state.copyWith(
          status: ChatStatus.success,
          messages: updatedMessages,
        ));
      },
    );
  }

  void _onClearHistory(ClearHistoryEvent event, Emitter<MentalHealthChatState> emit) {
    emit(const MentalHealthChatState());
  }
}
