import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatPage extends StatelessWidget {
  final String reportId;
  final String userId; // Current user ID (from Auth)

  const ChatPage({super.key, required this.reportId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatBloc>()..add(LoadMessages(reportId)),
      child: Scaffold(
        appBar: AppBar(title: const Text("Chat with Dispatch")),

        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatLoaded) {
                    return ListView.builder(
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state.messages[index];
                        final isMe = msg.senderId == userId;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(msg.content),
                          ),
                        );
                      },
                    );
                  } else if (state is ChatError) {
                    return Center(child: Text("Error: ${state.message}"));
                  }
                  return const Center(child: Text("No messages"));
                },
              ),
            ),
            _MessageInput(reportId: reportId, userId: userId),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  final String reportId;
  final String userId;

  const _MessageInput({required this.reportId, required this.userId});

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final _controller = TextEditingController();

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    final msg = Message(
      id: '', // Backend handles ID
      reportId: widget.reportId,
      senderId: widget.userId,
      content: _controller.text,
      timestamp: DateTime.now(),
      isRead: false,
    );
    context.read<ChatBloc>().add(SendMessageEvent(msg));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "Type a message..."),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _send),
        ],
      ),
    );
  }
}
