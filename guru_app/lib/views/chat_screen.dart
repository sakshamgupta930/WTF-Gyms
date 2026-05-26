import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import 'video_call_screen.dart';
import 'package:guru_app/theme/theme.dart';
import 'package:guru_app/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chat = Get.find<ChatController>();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _quickReplies = ['Got it 👍', 'Can we talk at 6?', 'Share plan?'];

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

  void _sendMessage({String? text}) {
    final payload = text ?? _textController.text;
    if (payload.trim().isEmpty) return;
    _chat.sendMessage(payload);
    if (text == null) _textController.clear();
    _chat.stopTyping();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Aarav (Lead Trainer)',
        subtitle: 'Real-time Chat with Coach',
        badgeText: 'Active',
        badgeColor: AppColors.success,
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.guruPrimary),
            onPressed: () {
              // Open mock video call directly
              Get.to(() => const VideoCallScreen(requestId: 'dev_mock_call'));
            },
            tooltip: 'Join Video Call',
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

              // Auto-scroll on new messages
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

                  final isMe = msg.senderId == 'dk_member';
                  return ChatBubble(
                    message: msg,
                    isMe: isMe,
                    senderRole: 'member',
                  );
                },
              );
            }),
          ),
          Obx(() {
            if (_chat.isTrainerTyping) {
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
                    const Text('Aarav is typing...', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          _buildQuickRepliesRow(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildQuickRepliesRow() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _quickReplies.length,
        itemBuilder: (context, idx) {
          final replyText = _quickReplies[idx];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(replyText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.guruPrimary)),
              onPressed: () => _sendMessage(text: replyText),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade200),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
          );
        },
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
                  hintText: 'Type a message...',
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
                    borderSide: const BorderSide(color: AppColors.guruPrimary),
                  ),
                ),
              ),
            ),
            AppSpacing.h8,
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.guruPrimary),
              onPressed: () => _sendMessage(),
            ),
          ],
        ),
      ),
    );
  }
}
