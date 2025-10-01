import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String senderName;
  final DateTime timestamp;
  final bool isFromCurrentUser;
  final bool isRead;
  final String? senderAvatar;

  const ChatBubble({
    super.key,
    required this.message,
    required this.senderName,
    required this.timestamp,
    required this.isFromCurrentUser,
    this.isRead = false,
    this.senderAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
        left: isFromCurrentUser ? 60 : 0,
        right: isFromCurrentUser ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment: isFromCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage: senderAvatar != null
                      ? NetworkImage(senderAvatar!)
                      : null,
                  child: senderAvatar == null
                      ? Text(
                          senderName.isNotEmpty
                              ? senderName[0].toUpperCase()
                              : '?',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  senderName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Container(
            decoration: BoxDecoration(
              color: isFromCurrentUser ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: isFromCurrentUser
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isFromCurrentUser
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isFromCurrentUser
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(timestamp),
                      style: AppTypography.bodySmall.copyWith(
                        color: isFromCurrentUser
                            ? AppColors.textOnPrimary.withValues(alpha: 0.7)
                            : AppColors.textHint,
                      ),
                    ),
                    if (isFromCurrentUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isRead ? Icons.done_all : Icons.done,
                        size: 16,
                        color: isRead
                            ? AppColors.accent
                            : AppColors.textOnPrimary.withValues(alpha: 0.7),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'agora';
    }
  }
}
