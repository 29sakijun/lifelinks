import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/friend_item_model.dart';
import '../../models/reaction_model.dart';
import '../../models/subtask_model.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../../widgets/image_zoom_dialog.dart';

class FriendItemDetailScreen extends StatefulWidget {
  final FriendItemModel friendItem;

  const FriendItemDetailScreen({super.key, required this.friendItem});

  @override
  State<FriendItemDetailScreen> createState() => _FriendItemDetailScreenState();
}

class _FriendItemDetailScreenState extends State<FriendItemDetailScreen> {
  String? _selectedReaction;
  final FirestoreService _firestoreService = FirestoreService();
  List<ReactionModel> _reactions = [];

  // リアルタイム更新用の状態変数
  bool? _isMainTaskCompleted;
  List<bool>? _subtaskCompletionStates;

  @override
  void initState() {
    super.initState();
    if (widget.friendItem.isDiaryMemo) {
      _loadReactions();
    }
    if (widget.friendItem.isTodo) {
      _isMainTaskCompleted = widget.friendItem.todo.isCompleted;
      _subtaskCompletionStates = widget.friendItem.todo.subtasks
          .map((subtask) => subtask.isCompleted)
          .toList();
    }
  }

  Future<void> _loadReactions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final targetId = widget.friendItem.diaryMemo.id;

    print('🔵 リアクション読み込み開始: targetId=$targetId');

    // リアクション一覧を取得
    _firestoreService.getReactions(targetId).listen((reactions) {
      print('✅ リアクション取得: ${reactions.length}件');
      for (final reaction in reactions) {
        print('  - ${reaction.userId}: ${reaction.reaction}');
      }
      if (mounted) {
        setState(() {
          _reactions = reactions;
        });
      }
    });

    // 自分のリアクションを取得
    final myReaction = await _firestoreService.getUserReaction(
      authProvider.user!.uid,
      targetId,
    );
    print('  自分のリアクション: ${myReaction?.reaction ?? "なし"}');
    if (mounted) {
      setState(() {
        _selectedReaction = myReaction?.reaction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          '${widget.friendItem.friendNickname}の投稿',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 友達情報
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: widget.friendItem.friendProfileImageUrl == null
                          ? Colors.white
                          : Colors.transparent,
                      backgroundImage: widget.friendItem.friendProfileImageUrl != null
                          ? NetworkImage(widget.friendItem.friendProfileImageUrl!)
                          : null,
                      radius: 28,
                      child: widget.friendItem.friendProfileImageUrl == null
                          ? Text(
                              widget.friendItem.friendNickname.isNotEmpty
                                  ? widget.friendItem.friendNickname[0]
                                  : '?',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.friendItem.friendNickname,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getItemType(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // コンテンツ
            _buildContent(),
            const SizedBox(height: 16),

            // リアクション（日記メモのみ）
            if (widget.friendItem.isDiaryMemo) _buildReactionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.friendItem.isShift) {
      return _buildShiftContent();
    } else if (widget.friendItem.isDiaryMemo) {
      return _buildDiaryContent();
    } else if (widget.friendItem.isTodo) {
      return _buildTodoContent();
    }
    return const SizedBox.shrink();
  }

  Widget _buildShiftContent() {
    final shift = widget.friendItem.shift;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.work, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  shift.workplaceName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${app_date_utils.DateUtils.formatTime(shift.startTime)} - ${app_date_utils.DateUtils.formatTime(shift.endTime)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (shift.memo.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'メモ',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(shift.memo),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryContent() {
    final diary = widget.friendItem.diaryMemo;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (diary.text.isNotEmpty) ...[
            Text(
              diary.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (diary.imageUrls.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: diary.imageUrls.length == 1 ? 1 : 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: diary.imageUrls.length == 1 ? 16 / 9 : 1,
              ),
              itemCount: diary.imageUrls.length,
              itemBuilder: (context, index) {
                final url = diary.imageUrls[index];
                return GestureDetector(
                  onTap: () {
                    ImageZoomDialog.show(
                      context,
                      diary.imageUrls,
                      initialIndex: index,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodoContent() {
    final todo = widget.friendItem.todo;
    final isCompleted = _isMainTaskCompleted ?? todo.isCompleted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _toggleTodoCompletion(),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isCompleted ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        todo.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // サブタスク表示（タップで完了/未完了切り替え可能）
            if (todo.subtasks.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'サブタスク (${_getCompletedSubtaskCount(todo)}/${todo.subtasks.length}完了)',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...todo.subtasks.asMap().entries.map((entry) {
                final index = entry.key;
                final subtask = entry.value;
                final isSubtaskCompleted =
                    _subtaskCompletionStates != null &&
                        index < _subtaskCompletionStates!.length
                    ? _subtaskCompletionStates![index]
                    : subtask.isCompleted;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () => _toggleSubtaskCompletion(index),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSubtaskCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: isSubtaskCompleted
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              subtask.title,
                              style: TextStyle(
                                decoration: isSubtaskCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.create, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '登録: ${app_date_utils.DateUtils.formatDateTime(todo.createdAt)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (todo.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    '締切: ${app_date_utils.DateUtils.formatDateTime(todo.dueDate!)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReactionSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_emotions,
                size: 20,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'リアクション',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // リアクションボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildReactionButton('👍', 'いいね'),
              _buildReactionButton('👌', '了解'),
              _buildReactionButton('😅', '無理'),
              _buildReactionButton('😲', 'びっくり'),
            ],
          ),

          // 自分のリアクション表示
          if (_selectedReaction != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedReaction!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'リアクションしました！',
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 他の人のリアクション表示
          if (_reactions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 18,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'みんなのリアクション',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildReactionSummary(),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Text(
              'まだリアクションはありません',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReactionSummary() {
    // リアクションをグループ化
    final reactionGroups = <String, int>{};
    for (final reaction in _reactions) {
      reactionGroups[reaction.reaction] =
          (reactionGroups[reaction.reaction] ?? 0) + 1;
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: reactionGroups.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.green.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReactionButton(String emoji, String label) {
    final isSelected = _selectedReaction == emoji;
    return GestureDetector(
      onTap: () => _handleReactionTap(emoji, isSelected),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [Colors.green.shade200, Colors.green.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? Colors.green.shade400 : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.green.shade900 : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReactionTap(String emoji, bool isSelected) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final targetId = widget.friendItem.diaryMemo.id;

    try {
      if (isSelected) {
        // リアクションを削除
        await _firestoreService.deleteReaction(
          authProvider.user!.uid,
          targetId,
        );
        setState(() {
          _selectedReaction = null;
        });
      } else {
        // リアクションを追加/更新
        final reaction = ReactionModel(
          id: '',
          userId: authProvider.user!.uid,
          targetId: targetId,
          reaction: emoji,
          createdAt: DateTime.now(),
        );
        await _firestoreService.addOrUpdateReaction(reaction);
        setState(() {
          _selectedReaction = emoji;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
      }
    }
  }

  String _getItemType() {
    if (widget.friendItem.isShift) return 'シフト';
    if (widget.friendItem.isDiaryMemo) return '日記メモ';
    if (widget.friendItem.isTodo) return 'TODO';
    return '';
  }

  int _getCompletedSubtaskCount(todo) {
    if (_subtaskCompletionStates == null) {
      return todo.subtasks.where((s) => s.isCompleted).length;
    }
    return _subtaskCompletionStates!.where((isCompleted) => isCompleted).length;
  }

  Future<void> _toggleTodoCompletion() async {
    if (!widget.friendItem.isTodo) return;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final todo = widget.friendItem.todo;
    final newCompletedState = !(_isMainTaskCompleted ?? todo.isCompleted);

    // UIを即座に更新
    setState(() {
      _isMainTaskCompleted = newCompletedState;
    });

    final updatedTodo = todo.copyWith(isCompleted: newCompletedState);

    try {
      await dataProvider.updateTodo(updatedTodo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newCompletedState ? 'TODOを完了しました' : 'TODOを未完了にしました'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // エラー時は元に戻す
      if (mounted) {
        setState(() {
          _isMainTaskCompleted = todo.isCompleted;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
      }
    }
  }

  Future<void> _toggleSubtaskCompletion(int index) async {
    if (!widget.friendItem.isTodo) return;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final todo = widget.friendItem.todo;

    if (index < 0 || index >= todo.subtasks.length) return;

    // 状態変数を初期化（まだの場合）
    if (_subtaskCompletionStates == null) {
      _subtaskCompletionStates = todo.subtasks
          .map((subtask) => subtask.isCompleted)
          .toList();
    }

    // 現在の完了状態を取得
    final currentState = _subtaskCompletionStates![index];
    final newCompletedState = !currentState;

    // UIを即座に更新
    setState(() {
      _subtaskCompletionStates![index] = newCompletedState;
    });

    // サブタスクのリストをコピーして更新
    final updatedSubtasks = List<SubtaskModel>.from(todo.subtasks);
    final subtask = updatedSubtasks[index];
    updatedSubtasks[index] = subtask.copyWith(isCompleted: newCompletedState);

    final updatedTodo = todo.copyWith(subtasks: updatedSubtasks);

    try {
      await dataProvider.updateTodo(updatedTodo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newCompletedState ? 'サブタスクを完了しました' : 'サブタスクを未完了にしました',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // エラー時は元に戻す
      if (mounted) {
        setState(() {
          _subtaskCompletionStates![index] = currentState;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
      }
    }
  }
}
