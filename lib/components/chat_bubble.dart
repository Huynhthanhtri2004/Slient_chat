import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';

/// Danh sách emoji dùng cho reaction (thả cảm xúc).
const List<String> kReactionEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String chatRoomId;
  final String currentUserId;
  /// Map emoji -> list of user IDs (từ Firestore: data['reactions']).
  final Map<String, dynamic>? reactions;
  final void Function(String messageId, String emoji)? onReaction;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageId,
    required this.chatRoomId,
    required this.currentUserId,
    this.reactions,
    this.onReaction,
  });

  void _showReactionPicker(BuildContext context) {
    if (onReaction == null) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - 56,
        position.dx + size.width,
        position.dy,
      ),
      items: kReactionEmojis
          .map((emoji) => PopupMenuItem<String>(
        value: emoji,
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ))
          .toList(),
    ). then((selectedEmoji) {
      if (selectedEmoji != null) onReaction!(messageId, selectedEmoji);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return GestureDetector(
      onLongPress: () => _showReactionPicker(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? (isDarkMode ? Colors.green.shade600 : Colors.green.shade500)
                    : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                message,
                style: TextStyle(
                  color: isCurrentUser
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ),
            if (reactions != null && reactions!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _buildReactionRow(context, isDarkMode),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReactionRow(BuildContext context, bool isDarkMode) {
    final list = <Widget>[];
    reactions!.forEach((emoji, value) {
      final List<dynamic> uids = value is List ? value : [];
      if (uids.isEmpty) return;
      final count = uids.length;
      final hasReacted = uids.contains(currentUserId);
      list.add(
        GestureDetector(
          onTap: () => onReaction?.call(messageId, emoji),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200)
                  .withValues(alpha: hasReacted ? 0.9 : 0.6),
              border: hasReacted
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                if (count > 1) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: list,
    );
  }
}
