import 'package:equatable/equatable.dart';

abstract class MentalHealthChatEvent extends Equatable {
  const MentalHealthChatEvent();
  @override
  List<Object> get props => [];
}

class SendMessageEvent extends MentalHealthChatEvent {
  final String message;
  const SendMessageEvent(this.message);
  @override
  List<Object> get props => [message];
}

class ClearHistoryEvent extends MentalHealthChatEvent {}
