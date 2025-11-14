import 'shift_model.dart';
import 'diary_memo_model.dart';
import 'todo_model.dart';

/// 友達の公開記事を識別するためのラッパーモデル
class FriendItemModel {
  final dynamic item;
  final String friendNickname;
  final String friendId;
  final bool isPublic;
  final bool isUnread;
  final String? friendProfileImageUrl;

  FriendItemModel({
    required this.item,
    required this.friendNickname,
    required this.friendId,
    required this.isPublic,
    this.isUnread = false,
    this.friendProfileImageUrl,
  });

  bool get isShift => item is ShiftModel;
  bool get isDiaryMemo => item is DiaryMemoModel;
  bool get isTodo => item is TodoModel;

  ShiftModel get shift => item as ShiftModel;
  DiaryMemoModel get diaryMemo => item as DiaryMemoModel;
  TodoModel get todo => item as TodoModel;
}
