import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/shift_model.dart';
import '../../models/diary_memo_model.dart';
import '../../models/todo_model.dart';
import '../../models/friend_item_model.dart';
import '../../models/friendship_model.dart';
import '../settings/settings_screen.dart';
import '../salary/salary_screen.dart';
import '../filter/filter_screen.dart';
import '../auth/auth_selection_screen.dart';
import '../../widgets/add_item_dialog.dart';
import '../../widgets/calendar_item_card.dart';
import '../../widgets/friend_item_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, bool> _expandedFriends = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<dynamic> _getEventsForDay(DateTime day, DataProvider dataProvider) {
    final events = <dynamic>[];

    // 自分のシフト
    final shifts = dataProvider.shifts.where((shift) {
      return isSameDay(shift.date, day);
    }).toList();
    events.addAll(shifts);

    // 自分の日記メモ
    final memos = dataProvider.diaryMemos.where((memo) {
      return isSameDay(memo.displayDate, day);
    }).toList();
    events.addAll(memos);

    // 自分のTODO（登録日から締切日まで表示）
    final todos = dataProvider.todos.where((todo) {
      // 締切がある場合：登録日から締切日までの期間に表示
      if (todo.dueDate != null) {
        final startDate = DateTime(
          todo.createdAt.year,
          todo.createdAt.month,
          todo.createdAt.day,
        );
        final endDate = DateTime(
          todo.dueDate!.year,
          todo.dueDate!.month,
          todo.dueDate!.day,
        );
        final checkDay = DateTime(day.year, day.month, day.day);
        return (checkDay.isAfter(startDate.subtract(const Duration(days: 1))) &&
            checkDay.isBefore(endDate.add(const Duration(days: 1))));
      }
      // 締切がない場合：登録日に表示
      return isSameDay(todo.createdAt, day);
    }).toList();
    events.addAll(todos);

    // 友達の公開シフト
    final friendsShifts = dataProvider.friendsPublicShifts.where((shift) {
      return isSameDay(shift.date, day);
    }).toList();
    for (final shift in friendsShifts) {
      // 友達のニックネームを取得
      final friendship = dataProvider.friendships.firstWhere(
        (f) => f.friendId == shift.userId,
        orElse: () => throw Exception('友達情報が見つかりません'),
      );
      // 未読チェック
      final isUnread =
          friendship.lastViewedAt == null ||
          shift.createdAt.isAfter(friendship.lastViewedAt!);
      events.add(
        FriendItemModel(
          item: shift,
          friendNickname: friendship.friendNickname,
          friendId: shift.userId,
          isPublic: shift.isPublic,
          isUnread: isUnread,
          friendProfileImageUrl: friendship.friendProfileImageUrl,
        ),
      );
    }

    // 友達の公開日記メモ
    final friendsMemos = dataProvider.friendsPublicDiaryMemos.where((memo) {
      return isSameDay(memo.displayDate, day);
    }).toList();
    for (final memo in friendsMemos) {
      // 友達のニックネームを取得
      final friendship = dataProvider.friendships.firstWhere(
        (f) => f.friendId == memo.userId,
        orElse: () => throw Exception('友達情報が見つかりません'),
      );
      // 未読チェック
      final isUnread =
          friendship.lastViewedAt == null ||
          memo.createdAt.isAfter(friendship.lastViewedAt!);
      events.add(
        FriendItemModel(
          item: memo,
          friendNickname: friendship.friendNickname,
          friendId: memo.userId,
          isPublic: memo.isPublic,
          isUnread: isUnread,
          friendProfileImageUrl: friendship.friendProfileImageUrl,
        ),
      );
    }

    // 友達の公開TODO（登録日から締切日まで表示）
    final friendsTodos = dataProvider.friendsPublicTodos.where((todo) {
      // 締切がある場合：登録日から締切日までの期間に表示
      if (todo.dueDate != null) {
        final startDate = DateTime(
          todo.createdAt.year,
          todo.createdAt.month,
          todo.createdAt.day,
        );
        final endDate = DateTime(
          todo.dueDate!.year,
          todo.dueDate!.month,
          todo.dueDate!.day,
        );
        final checkDay = DateTime(day.year, day.month, day.day);
        return (checkDay.isAfter(startDate.subtract(const Duration(days: 1))) &&
            checkDay.isBefore(endDate.add(const Duration(days: 1))));
      }
      // 締切がない場合：登録日に表示
      return isSameDay(todo.createdAt, day);
    }).toList();
    for (final todo in friendsTodos) {
      // 友達のニックネームを取得
      final friendship = dataProvider.friendships.firstWhere(
        (f) => f.friendId == todo.userId,
        orElse: () => throw Exception('友達情報が見つかりません'),
      );
      // 未読チェック
      final isUnread =
          friendship.lastViewedAt == null ||
          todo.createdAt.isAfter(friendship.lastViewedAt!);
      events.add(
        FriendItemModel(
          item: todo,
          friendNickname: friendship.friendNickname,
          friendId: todo.userId,
          isPublic: todo.isPublic,
          isUnread: isUnread,
          friendProfileImageUrl: friendship.friendProfileImageUrl,
        ),
      );
    }

    return events;
  }

  void _showAddDialog(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(selectedDate: selectedDate),
    );
  }

  Widget _buildMarkers(List events) {
    if (events.isEmpty) return const SizedBox.shrink();

    bool hasMyShift = false;
    bool hasMyDiaryMemo = false;
    bool hasMyTodo = false;
    bool hasFriendUnread = false;

    for (final event in events) {
      // 自分の投稿のみカウント
      if (event is ShiftModel) {
        hasMyShift = true;
      } else if (event is DiaryMemoModel) {
        hasMyDiaryMemo = true;
      } else if (event is TodoModel) {
        hasMyTodo = true;
      }
      // 友達の未読投稿をチェック
      else if (event is FriendItemModel && event.isUnread) {
        hasFriendUnread = true;
      }
    }

    return Positioned(
      bottom: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasMyShift)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          if (hasMyDiaryMemo)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          if (hasMyTodo)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          if (hasFriendUnread)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'LifeLink',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FilterScreen()),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: const Text(
                '¥',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalaryScreen()),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.grey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 匿名ユーザー用バナー
          if (authProvider.authService.isAnonymousUser())
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[300]!, Colors.orange[400]!],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '匿名アカウントで利用中です。アカウントをリンクしてデータを保護しましょう',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AuthSelectionScreen(isLinkMode: true),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange[700],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'リンク',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom:
                    _calendarFormat == CalendarFormat.week ||
                        _calendarFormat == CalendarFormat.twoWeeks
                    ? 16.0
                    : 0.0,
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                locale: 'ja_JP',
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) => _getEventsForDay(day, dataProvider),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    return _buildMarkers(events);
                  },
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  formatButtonTextStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  titleTextStyle:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ) ??
                      const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  cellMargin: const EdgeInsets.all(4.0),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  defaultDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  weekendDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  holidayDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          Expanded(child: _buildEventList(dataProvider)),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          onPressed: () =>
              _showAddDialog(context, _selectedDay ?? DateTime.now()),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildEventList(DataProvider dataProvider) {
    if (_selectedDay == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '日付を選択してください',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final events = _getEventsForDay(_selectedDay!, dataProvider);

    // 自分の投稿と友達の投稿を分離
    final myEvents = events
        .where((event) => event is! FriendItemModel)
        .toList();
    final friendEvents = events.whereType<FriendItemModel>().toList();

    if (myEvents.isEmpty && friendEvents.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'この日の予定はありません',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '＋ボタンで新しい予定を追加できます',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // 友達毎にグループ化
    final friendGroups = <String, List<FriendItemModel>>{};
    for (final event in friendEvents) {
      friendGroups.putIfAbsent(event.friendId, () => []).add(event);
    }

    // 友達を表示順でソート
    final sortedFriendships =
        dataProvider.friendships
            .where((f) => friendGroups.containsKey(f.friendId))
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // 自分の投稿
        if (myEvents.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...myEvents.map((event) => CalendarItemCard(item: event)),
        ],

        // 友達毎のセクション
        if (sortedFriendships.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...sortedFriendships.map((friendship) {
            final friendPosts = friendGroups[friendship.friendId] ?? [];
            final hasUnread = _hasUnreadPosts(friendPosts, friendship);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                backgroundColor: Colors.blue[50],
                collapsedBackgroundColor: Colors.blue[50],
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: friendship.friendProfileImageUrl != null
                      ? NetworkImage(friendship.friendProfileImageUrl!)
                      : null,
                  backgroundColor: friendship.friendColor,
                  child: friendship.friendProfileImageUrl == null
                      ? Text(
                          friendship.friendNickname[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        friendship.friendNickname,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (hasUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  '${friendPosts.length}件の投稿',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                initiallyExpanded:
                    _expandedFriends[friendship.friendId] ?? false,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedFriends[friendship.friendId] = expanded;
                  });
                },
                children: friendPosts
                    .map(
                      (friendEvent) => FriendItemCard(friendItem: friendEvent),
                    )
                    .toList(),
              ),
            );
          }),
        ],
        const SizedBox(height: 80), // FABのためのスペース
      ],
    );
  }

  bool _hasUnreadPosts(
    List<FriendItemModel> posts,
    FriendshipModel friendship,
  ) {
    if (friendship.lastViewedAt == null) return posts.isNotEmpty;

    for (final post in posts) {
      DateTime postDate;
      if (post.isShift) {
        postDate = post.shift.createdAt;
      } else if (post.isDiaryMemo) {
        postDate = post.diaryMemo.createdAt;
      } else if (post.isTodo) {
        postDate = post.todo.createdAt;
      } else {
        continue;
      }

      if (postDate.isAfter(friendship.lastViewedAt!)) {
        return true;
      }
    }
    return false;
  }
}
