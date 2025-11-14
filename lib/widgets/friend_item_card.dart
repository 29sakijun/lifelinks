import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/friend_item_model.dart';
import '../providers/data_provider.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../screens/friends/friend_item_detail_screen.dart';

class FriendItemCard extends StatelessWidget {
  final FriendItemModel friendItem;

  const FriendItemCard({super.key, required this.friendItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          // 投稿を開いた時に既読処理
          if (friendItem.isUnread) {
            final dataProvider = Provider.of<DataProvider>(
              context,
              listen: false,
            );
            final friendship = dataProvider.friendships.firstWhere(
              (f) => f.friendId == friendItem.friendId,
            );
            final updated = friendship.copyWith(lastViewedAt: DateTime.now());
            await dataProvider.updateFriendship(updated);
          }

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FriendItemDetailScreen(friendItem: friendItem),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getIconColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(_getIcon(), size: 24, color: _getIconColor()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            friendItem.friendNickname,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (friendItem.isUnread)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildSubtitle(context),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    if (friendItem.isShift) {
      return Text(
        '${friendItem.shift.workplaceName} - ${app_date_utils.DateUtils.formatTime(friendItem.shift.startTime)}',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      );
    } else if (friendItem.isDiaryMemo) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            friendItem.diaryMemo.text.isEmpty
                ? '[画像のみ]'
                : friendItem.diaryMemo.text.length > 30
                ? '${friendItem.diaryMemo.text.substring(0, 30)}...'
                : friendItem.diaryMemo.text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      );
    } else if (friendItem.isTodo) {
      final todo = friendItem.todo;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todo.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          if (todo.subtasks.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'サブタスク: ${todo.subtasks.where((s) => s.isCompleted).length}/${todo.subtasks.length}完了',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            '登録: ${app_date_utils.DateUtils.formatDateTime(todo.createdAt)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
          if (todo.dueDate != null) ...[
            const SizedBox(height: 2),
            Text(
              '締切: ${app_date_utils.DateUtils.formatDateTime(todo.dueDate!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      );
    }
    return const SizedBox.shrink();
  }

  IconData _getIcon() {
    if (friendItem.isShift) return Icons.work;
    if (friendItem.isDiaryMemo) return Icons.menu_book;
    if (friendItem.isTodo) return Icons.check_box;
    return Icons.help;
  }

  Color _getIconColor() {
    if (friendItem.isShift) return Colors.blue;
    if (friendItem.isDiaryMemo) return Colors.orange;
    if (friendItem.isTodo) return Colors.green;
    return Colors.grey;
  }
}
