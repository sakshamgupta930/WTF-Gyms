import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/models.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final String senderRole; // 'trainer' or 'member'

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.senderRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Member bubble is primary blue, trainer bubble is primary red (if isMe)
    // If not isMe, it defaults to grey.
    Color bubbleBg;
    if (isMe) {
      bubbleBg = senderRole == 'trainer' ? AppColors.trainerPrimary : AppColors.guruPrimary;
    } else {
      bubbleBg = Colors.grey.shade100;
    }

    final textColor = isMe
        ? Colors.white
        : AppColors.textPrimaryLight;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppSpacing.s12),
            topRight: const Radius.circular(AppSpacing.s12),
            bottomLeft: Radius.circular(isMe ? AppSpacing.s12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : AppSpacing.s12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : AppColors.textSecondaryLight,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(message.status),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    if (status == 'sending') {
      return const SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeWidth: 1.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
        ),
      );
    } else if (status == 'sent') {
      return const Icon(
        Icons.done,
        size: 12,
        color: Colors.white70,
      );
    } else if (status == 'read') {
      return const Icon(
        Icons.done_all,
        size: 12,
        color: Colors.white,
      );
    }
    return const SizedBox.shrink();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
