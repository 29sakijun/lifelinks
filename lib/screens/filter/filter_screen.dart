import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/shift_model.dart';
import '../../models/diary_memo_model.dart';
import '../../models/todo_model.dart';
import '../../models/friend_item_model.dart';
import '../../widgets/calendar_item_card.dart';
import '../../widgets/friend_item_card.dart';

enum FilterType { all, shift, diary, todo }

enum VisibilityFilter { all, myOnly, publicOnly }

enum DateFilterType { none, single, range, month }

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  FilterType _filterType = FilterType.all;
  VisibilityFilter _visibilityFilter = VisibilityFilter.all;
  String? _selectedFriendId;
  DateFilterType _dateFilterType = DateFilterType.none;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _selectedMonth;
  bool _isFiltersExpanded = false;
  bool _isSelectionMode = false;
  Set<int> _selectedIndices = {};

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    // フィルタリング
    List<dynamic> filteredItems = [];

    // 友達フィルタが選択されている場合
    if (_selectedFriendId != null) {
      final friendship = dataProvider.friendships.firstWhere(
        (f) => f.friendId == _selectedFriendId,
      );

      // 友達の公開投稿を取得
      switch (_filterType) {
        case FilterType.all:
          final shifts = dataProvider.friendsPublicShifts.where(
            (s) => s.userId == _selectedFriendId,
          );
          final memos = dataProvider.friendsPublicDiaryMemos.where(
            (m) => m.userId == _selectedFriendId,
          );
          final todos = dataProvider.friendsPublicTodos.where(
            (t) => t.userId == _selectedFriendId,
          );

          for (final shift in shifts) {
            filteredItems.add(
              FriendItemModel(
                item: shift,
                friendNickname: friendship.friendNickname,
                friendId: shift.userId,
                isPublic: shift.isPublic,
                isUnread: false,
                friendProfileImageUrl: friendship.friendProfileImageUrl,
              ),
            );
          }
          for (final memo in memos) {
            filteredItems.add(
              FriendItemModel(
                item: memo,
                friendNickname: friendship.friendNickname,
                friendId: memo.userId,
                isPublic: memo.isPublic,
                isUnread: false,
                friendProfileImageUrl: friendship.friendProfileImageUrl,
              ),
            );
          }
          for (final todo in todos) {
            filteredItems.add(
              FriendItemModel(
                item: todo,
                friendNickname: friendship.friendNickname,
                friendId: todo.userId,
                isPublic: todo.isPublic,
                isUnread: false,
                friendProfileImageUrl: friendship.friendProfileImageUrl,
              ),
            );
          }
          break;
        case FilterType.shift:
          final shifts = dataProvider.friendsPublicShifts.where(
            (s) => s.userId == _selectedFriendId,
          );
          for (final shift in shifts) {
            filteredItems.add(
              FriendItemModel(
                item: shift,
                friendNickname: friendship.friendNickname,
                friendId: shift.userId,
                isPublic: shift.isPublic,
                isUnread: false,
                friendProfileImageUrl: friendship.friendProfileImageUrl,
              ),
            );
          }
          break;
        case FilterType.diary:
          final memos = dataProvider.friendsPublicDiaryMemos.where(
            (m) => m.userId == _selectedFriendId,
          );
          for (final memo in memos) {
            filteredItems.add(
              FriendItemModel(
                item: memo,
                friendNickname: friendship.friendNickname,
                friendId: memo.userId,
                isPublic: memo.isPublic,
                isUnread: false,
                friendProfileImageUrl: friendship.friendProfileImageUrl,
              ),
            );
          }
          break;
        case FilterType.todo:
          final todos = dataProvider.friendsPublicTodos.where(
            (t) => t.userId == _selectedFriendId,
          );
          for (final todo in todos) {
            filteredItems.add(
              FriendItemModel(
                item: todo,
                friendNickname: friendship.friendNickname,
                friendId: todo.userId,
                isPublic: todo.isPublic,
                isUnread: false,
                friendProfileImageUrl: friendship.friendProfileImageUrl,
              ),
            );
          }
          break;
      }
    } else {
      // 自分の投稿を取得
      switch (_filterType) {
        case FilterType.all:
          filteredItems.addAll(dataProvider.shifts);
          filteredItems.addAll(dataProvider.diaryMemos);
          filteredItems.addAll(dataProvider.todos);
          break;
        case FilterType.shift:
          filteredItems.addAll(dataProvider.shifts);
          break;
        case FilterType.diary:
          filteredItems.addAll(dataProvider.diaryMemos);
          break;
        case FilterType.todo:
          filteredItems.addAll(dataProvider.todos);
          break;
      }
    }

    // 公開フィルタ（友達フィルタが選択されていない場合のみ）
    if (_selectedFriendId == null) {
      switch (_visibilityFilter) {
        case VisibilityFilter.publicOnly:
          filteredItems = filteredItems.where((item) {
            if (item is ShiftModel) return item.isPublic;
            if (item is DiaryMemoModel) return item.isPublic;
            if (item is TodoModel) return item.isPublic;
            return false;
          }).toList();
          break;
        case VisibilityFilter.myOnly:
          filteredItems = filteredItems.where((item) {
            if (item is ShiftModel) return !item.isPublic;
            if (item is DiaryMemoModel) return !item.isPublic;
            if (item is TodoModel) return !item.isPublic;
            return false;
          }).toList();
          break;
        case VisibilityFilter.all:
          // すべて表示（フィルタなし）
          break;
      }
    }

    // 日付フィルタ
    switch (_dateFilterType) {
      case DateFilterType.single:
        if (_selectedDate != null) {
          filteredItems = filteredItems.where((item) {
            DateTime itemDate;
            if (item is FriendItemModel) {
              if (item.isShift) {
                itemDate = item.shift.date;
              } else if (item.isDiaryMemo) {
                itemDate = item.diaryMemo.displayDate;
              } else if (item.isTodo) {
                itemDate = item.todo.dueDate ?? item.todo.createdAt;
              } else {
                return false;
              }
            } else if (item is ShiftModel) {
              itemDate = item.date;
            } else if (item is DiaryMemoModel) {
              itemDate = item.displayDate;
            } else if (item is TodoModel) {
              itemDate = item.dueDate ?? item.createdAt;
            } else {
              return false;
            }
            return itemDate.year == _selectedDate!.year &&
                itemDate.month == _selectedDate!.month &&
                itemDate.day == _selectedDate!.day;
          }).toList();
        }
        break;
      case DateFilterType.range:
        if (_startDate != null && _endDate != null) {
          filteredItems = filteredItems.where((item) {
            DateTime itemDate;
            if (item is FriendItemModel) {
              if (item.isShift) {
                itemDate = item.shift.date;
              } else if (item.isDiaryMemo) {
                itemDate = item.diaryMemo.displayDate;
              } else if (item.isTodo) {
                itemDate = item.todo.dueDate ?? item.todo.createdAt;
              } else {
                return false;
              }
            } else if (item is ShiftModel) {
              itemDate = item.date;
            } else if (item is DiaryMemoModel) {
              itemDate = item.displayDate;
            } else if (item is TodoModel) {
              itemDate = item.dueDate ?? item.createdAt;
            } else {
              return false;
            }
            // 時刻を00:00:00に設定して比較
            final itemDateOnly = DateTime(
              itemDate.year,
              itemDate.month,
              itemDate.day,
            );
            final startDateOnly = DateTime(
              _startDate!.year,
              _startDate!.month,
              _startDate!.day,
            );
            final endDateOnly = DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
            );
            return itemDateOnly.isAtSameMomentAs(startDateOnly) ||
                itemDateOnly.isAtSameMomentAs(endDateOnly) ||
                (itemDateOnly.isAfter(startDateOnly) &&
                    itemDateOnly.isBefore(endDateOnly));
          }).toList();
        }
        break;
      case DateFilterType.month:
        if (_selectedMonth != null) {
          filteredItems = filteredItems.where((item) {
            DateTime itemDate;
            if (item is FriendItemModel) {
              if (item.isShift) {
                itemDate = item.shift.date;
              } else if (item.isDiaryMemo) {
                itemDate = item.diaryMemo.displayDate;
              } else if (item.isTodo) {
                itemDate = item.todo.dueDate ?? item.todo.createdAt;
              } else {
                return false;
              }
            } else if (item is ShiftModel) {
              itemDate = item.date;
            } else if (item is DiaryMemoModel) {
              itemDate = item.displayDate;
            } else if (item is TodoModel) {
              itemDate = item.dueDate ?? item.createdAt;
            } else {
              return false;
            }
            return itemDate.year == _selectedMonth!.year &&
                itemDate.month == _selectedMonth!.month;
          }).toList();
        }
        break;
      case DateFilterType.none:
        break;
    }

    // 日付順にソート
    filteredItems.sort((a, b) {
      DateTime dateA;
      DateTime dateB;

      if (a is FriendItemModel) {
        if (a.isShift) {
          dateA = a.shift.date;
        } else if (a.isDiaryMemo) {
          dateA = a.diaryMemo.displayDate;
        } else if (a.isTodo) {
          dateA = a.todo.dueDate ?? a.todo.createdAt;
        } else {
          dateA = DateTime.now();
        }
      } else if (a is ShiftModel) {
        dateA = a.date;
      } else if (a is DiaryMemoModel) {
        dateA = a.displayDate;
      } else if (a is TodoModel) {
        dateA = a.dueDate ?? a.createdAt;
      } else {
        dateA = DateTime.now();
      }

      if (b is FriendItemModel) {
        if (b.isShift) {
          dateB = b.shift.date;
        } else if (b.isDiaryMemo) {
          dateB = b.diaryMemo.displayDate;
        } else if (b.isTodo) {
          dateB = b.todo.dueDate ?? b.todo.createdAt;
        } else {
          dateB = DateTime.now();
        }
      } else if (b is ShiftModel) {
        dateB = b.date;
      } else if (b is DiaryMemoModel) {
        dateB = b.displayDate;
      } else if (b is TodoModel) {
        dateB = b.dueDate ?? b.createdAt;
      } else {
        dateB = DateTime.now();
      }

      return dateB.compareTo(dateA); // 新しい順
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode ? '${_selectedIndices.length}件選択' : 'フィルタ',
        ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedIndices.clear();
                  _isSelectionMode = false;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  if (_selectedIndices.length == filteredItems.length) {
                    _selectedIndices.clear();
                  } else {
                    _selectedIndices = {
                      for (var i = 0; i < filteredItems.length; i++) i,
                    };
                  }
                });
              },
            ),
            if (_selectedIndices.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('削除確認'),
                      content: Text('選択した${_selectedIndices.length}件を削除しますか？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('削除'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    // 削除処理
                    final indices = _selectedIndices.toList()
                      ..sort((a, b) => b.compareTo(a));
                    for (final index in indices) {
                      final item = filteredItems[index];
                      if (item is ShiftModel) {
                        await dataProvider.deleteShift(item.id);
                      } else if (item is DiaryMemoModel) {
                        await dataProvider.deleteDiaryMemo(item.id);
                      } else if (item is TodoModel) {
                        await dataProvider.deleteTodo(item.id);
                      } else if (item is FriendItemModel) {
                        if (item.isShift) {
                          await dataProvider.deleteShift(item.shift.id);
                        } else if (item.isDiaryMemo) {
                          await dataProvider.deleteDiaryMemo(item.diaryMemo.id);
                        } else if (item.isTodo) {
                          await dataProvider.deleteTodo(item.todo.id);
                        }
                      }
                    }
                    setState(() {
                      _selectedIndices.clear();
                      _isSelectionMode = false;
                    });
                  }
                },
              ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
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
            child: Column(
              children: [
                SegmentedButton<FilterType>(
                  segments: const [
                    ButtonSegment(value: FilterType.all, label: Text('すべて')),
                    ButtonSegment(value: FilterType.shift, label: Text('シフト')),
                    ButtonSegment(value: FilterType.diary, label: Text('日記')),
                    ButtonSegment(value: FilterType.todo, label: Text('TODO')),
                  ],
                  selected: {_filterType},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<FilterType> newSelection) {
                    setState(() {
                      _filterType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text(
                    '詳細フィルタ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: Icon(
                    _isFiltersExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isFiltersExpanded = expanded;
                    });
                  },
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.all(16),
                  shape: const Border(),
                  collapsedShape: const Border(),
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      '投稿者で絞り込み',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                        labelText: '友達を選択',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      value: _selectedFriendId,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('自分の投稿'),
                        ),
                        ...dataProvider.friendships.map((friendship) {
                          return DropdownMenuItem<String?>(
                            value: friendship.friendId,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      friendship.friendProfileImageUrl == null
                                          ? friendship.friendColor
                                          : Colors.transparent,
                                  backgroundImage:
                                      friendship.friendProfileImageUrl != null
                                          ? NetworkImage(
                                              friendship.friendProfileImageUrl!,
                                            )
                                          : null,
                                  radius: 12,
                                  child: friendship.friendProfileImageUrl == null
                                      ? Text(
                                          friendship.friendNickname.isNotEmpty
                                              ? friendship.friendNickname[0]
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(friendship.friendNickname),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFriendId = value;
                          // 友達を選択したら公開設定フィルタをリセット
                          if (value != null) {
                            _visibilityFilter = VisibilityFilter.all;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '日付で絞り込み',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (_dateFilterType != DateFilterType.none)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _dateFilterType = DateFilterType.none;
                                _selectedDate = null;
                                _startDate = null;
                                _endDate = null;
                                _selectedMonth = null;
                              });
                            },
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('クリア'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SegmentedButton<DateFilterType>(
                      segments: const [
                        ButtonSegment(
                          value: DateFilterType.none,
                          label: Text('なし'),
                        ),
                        ButtonSegment(
                          value: DateFilterType.single,
                          label: Text('日'),
                        ),
                        ButtonSegment(
                          value: DateFilterType.range,
                          label: Text('期間'),
                        ),
                        ButtonSegment(
                          value: DateFilterType.month,
                          label: Text('月'),
                        ),
                      ],
                      selected: {_dateFilterType},
                      showSelectedIcon: false,
                      onSelectionChanged: (Set<DateFilterType> newSelection) {
                        setState(() {
                          _dateFilterType = newSelection.first;
                          if (_dateFilterType == DateFilterType.none) {
                            _selectedDate = null;
                            _startDate = null;
                            _endDate = null;
                            _selectedMonth = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    if (_dateFilterType == DateFilterType.single) ...[
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            locale: const Locale('ja', 'JP'),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          _selectedDate != null
                              ? DateFormat('yyyy年M月d日').format(_selectedDate!)
                              : '日付を選択',
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ] else if (_dateFilterType == DateFilterType.range) ...[
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: _endDate ?? DateTime(2030),
                            locale: const Locale('ja', 'JP'),
                          );
                          if (picked != null) {
                            setState(() {
                              _startDate = picked;
                              if (_endDate != null &&
                                  _endDate!.isBefore(_startDate!)) {
                                _endDate = null;
                              }
                            });
                          }
                        },
                        icon: const Icon(Icons.event, size: 18),
                        label: Text(
                          _startDate != null
                              ? DateFormat('yyyy年M月d日').format(_startDate!)
                              : '開始日を選択',
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _endDate ?? _startDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime(2020),
                            lastDate: DateTime(2030),
                            locale: const Locale('ja', 'JP'),
                          );
                          if (picked != null) {
                            setState(() {
                              _endDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.event_available, size: 18),
                        label: Text(
                          _endDate != null
                              ? DateFormat('yyyy年M月d日').format(_endDate!)
                              : '終了日を選択',
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ] else if (_dateFilterType == DateFilterType.month) ...[
                      TextButton.icon(
                        onPressed: () async {
                          // 年月選択ダイアログを表示
                          final year = await showDialog<int>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('年を選択'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 11, // 2020-2030
                                  itemBuilder: (context, index) {
                                    final yearValue = 2020 + index;
                                    return ListTile(
                                      title: Text('$yearValue年'),
                                      onTap: () {
                                        Navigator.pop(context, yearValue);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                          if (year == null) return;

                          final month = await showDialog<int>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('月を選択'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 12,
                                  itemBuilder: (context, index) {
                                    final monthValue = index + 1;
                                    return ListTile(
                                      title: Text('$monthValue月'),
                                      onTap: () {
                                        Navigator.pop(context, monthValue);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                          if (month == null) return;

                          setState(() {
                            _selectedMonth = DateTime(year, month, 1);
                          });
                        },
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: Text(
                          _selectedMonth != null
                              ? DateFormat('yyyy年M月').format(_selectedMonth!)
                              : '年月を選択',
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      '公開設定で絞り込み',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<VisibilityFilter>(
                      segments: const [
                        ButtonSegment(
                          value: VisibilityFilter.all,
                          label: Text('すべて'),
                        ),
                        ButtonSegment(
                          value: VisibilityFilter.myOnly,
                          label: Text('自分のみ'),
                        ),
                        ButtonSegment(
                          value: VisibilityFilter.publicOnly,
                          label: Text('公開のみ'),
                        ),
                      ],
                      selected: {_visibilityFilter},
                      showSelectedIcon: false,
                      onSelectionChanged: _selectedFriendId == null
                          ? (Set<VisibilityFilter> newSelection) {
                              setState(() {
                                _visibilityFilter = newSelection.first;
                              });
                            }
                          : null, // 友達選択時は無効化
                    ),
                    if (_selectedFriendId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '※ 友達の投稿は常に公開のみ表示されます',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          '該当するデータがありません',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isSelected = _selectedIndices.contains(index);

                      Widget card;
                      if (item is FriendItemModel) {
                        card = FriendItemCard(friendItem: item);
                      } else {
                        card = CalendarItemCard(item: item, showDate: true);
                      }

                      if (!_isSelectionMode) {
                        return card;
                      }

                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedIndices.remove(index);
                            } else {
                              _selectedIndices.add(index);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            children: [
                              card,
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    isSelected ? Icons.check : null,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
