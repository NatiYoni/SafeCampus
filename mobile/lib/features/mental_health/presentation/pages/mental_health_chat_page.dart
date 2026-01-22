import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat/mental_health_chat_bloc.dart';
import '../bloc/chat/mental_health_chat_event.dart';
import '../bloc/chat/mental_health_chat_state.dart';
import '../../../../injection_container.dart';

class MentalHealthChatPage extends StatefulWidget {
  const MentalHealthChatPage({super.key});

  @override
  State<MentalHealthChatPage> createState() => _MentalHealthChatPageState();
}

class _MentalHealthChatPageState extends State<MentalHealthChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MentalHealthChatBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Companion'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                // Confirm clear?
              },
            )
          ],
        ),
        body: Column(
          children: [
            // Safety Disclaimer
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber.shade100,
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.brown),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "I am an AI, not a therapist. In a crisis, please use the SOS button on the dashboard.",
                      style: TextStyle(color: Colors.brown, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            // Chat List
            Expanded(
              child: BlocConsumer<MentalHealthChatBloc, MentalHealthChatState>(
                listener: (context, state) {
                  if (state.status == ChatStatus.success || state.status == ChatStatus.loading) {
                    _scrollToBottom();
                  }
                  if (state.status == ChatStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage)),
                    );
                  }
                },
                builder: (context, state) {
                   if (state.messages.isEmpty) {
                     return Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                           const SizedBox(height: 16),
                           const Text("Say Hello! I'm here to listen.", style: TextStyle(color: Colors.grey)),
                         ],
                       ),
                     );
                   }

                   return ListView.builder(
                     controller: _scrollController,
                     padding: const EdgeInsets.all(16),
                     itemCount: state.messages.length + (state.status == ChatStatus.loading ? 1 : 0),
                     itemBuilder: (context, index) {
                       if (index == state.messages.length) {
                         return const Align(
                           alignment: Alignment.centerLeft,
                           child: Padding(
                             padding: EdgeInsets.all(8.0),
                             child: CircularProgressIndicator(strokeWidth: 2),
                           ),
                         );
                       }
                       
                       final msg = state.messages[index];
                       return Align(
                         alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                         child: Container(
                           constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                           margin: const EdgeInsets.symmetric(vertical: 4),
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(
                             color: msg.isUser ? Colors.teal : Colors.grey.shade200,
                             borderRadius: BorderRadius.circular(16),
                           ),
                           child: Text(
                             msg.content,
                             style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87),
                           ),
                         ),
                       );
                     },
                   );
                },
              ),
            ),

            // Input Area
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<MentalHealthChatBloc, MentalHealthChatState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onSubmitted: (value) {
                             if (value.trim().isNotEmpty) {
                               context.read<MentalHealthChatBloc>().add(SendMessageEvent(value));
                               _controller.clear();
                             }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        icon: const Icon(Icons.send),
                        onPressed: state.status == ChatStatus.loading 
                          ? null 
                          : () {
                             if (_controller.text.trim().isNotEmpty) {
                               context.read<MentalHealthChatBloc>().add(SendMessageEvent(_controller.text));
                               _controller.clear();
                             }
                          },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
