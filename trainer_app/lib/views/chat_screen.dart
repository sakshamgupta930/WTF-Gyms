import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import 'video_call_screen.dart';
import 'package:trainer_app/theme/theme.dart';
import 'package:trainer_app/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chat = Get.find<ChatController>();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    _chat.sendMessage(_textController.text);
    _textController.clear();
    _chat.stopTyping();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'DK (Member)',
        subtitle: 'Real-time Chat with DK',
        badgeText: 'Active',
        badgeColor: AppColors.success,
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.trainerPrimary),
            onPressed: () {
              // Open mock video call directly
              Get.to(() => const VideoCallScreen(requestId: 'dev_mock_call'));
            },
            tooltip: 'Launch Video Call',
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final msgs = _chat.messages;

              if (msgs.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.chat_bubble_outline,
                  title: 'No messages yet',
                  description: 'No messages yet. Start the conversation.',
                );
              }

              // Trigger auto-scroll on new message
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final msg = msgs[index];

                  if (msg.senderId == 'system') {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          msg.text,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final isMe = msg.senderId == 'aarav_trainer';
                  return ChatBubble(
                    message: msg,
                    isMe: isMe,
                    senderRole: 'trainer',
                  );
                },
              );
            }),
          ),
          Obx(() {
            if (_chat.isMemberTyping) {
              return Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.textSecondaryLight),
                      ),
                    ),
                    AppSpacing.h8,
                    const Text('DK is typing...', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    _chat.startTyping();
                  } else {
                    _chat.stopTyping();
                  }
                },
                onFieldSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type a reply...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.trainerPrimary),
                  ),
                ),
              ),
            ),
            AppSpacing.h8,
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.trainerPrimary),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
