import 'package:flutter/foundation.dart';
import '../models/workplace_model.dart';
import '../models/shift_model.dart';
import '../models/diary_memo_model.dart';
import '../models/todo_model.dart';
import '../models/friendship_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../utils/salary_calculator.dart';

class DataProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<WorkplaceModel> _workplaces = [];
  List<ShiftModel> _shifts = [];
  List<DiaryMemoModel> _diaryMemos = [];
  List<TodoModel> _todos = [];
  List<FriendshipModel> _friendships = [];
  final Set<String> _friendImageSyncInProgress = {};
  
  // 友達の公開データ
  List<ShiftModel> _friendsPublicShifts = [];
  List<DiaryMemoModel> _friendsPublicDiaryMemos = [];
  List<TodoModel> _friendsPublicTodos = [];

  List<WorkplaceModel> get workplaces => _workplaces;
  List<ShiftModel> get shifts => _shifts;
  List<DiaryMemoModel> get diaryMemos => _diaryMemos;
  List<TodoModel> get todos => _todos;
  List<FriendshipModel> get friendships => _friendships;
  
  // 友達の公開データ
  List<ShiftModel> get friendsPublicShifts => _friendsPublicShifts;
  List<DiaryMemoModel> get friendsPublicDiaryMemos => _friendsPublicDiaryMemos;
  List<TodoModel> get friendsPublicTodos => _friendsPublicTodos;

  // ==================== Workplace ====================

  void loadWorkplaces(String userId) {
    _firestoreService.getWorkplaces(userId).listen((workplaces) {
      _workplaces = workplaces;
      notifyListeners();
    });
  }

  Future<void> addWorkplace(WorkplaceModel workplace) async {
    await _firestoreService.addWorkplace(workplace);
    // 給料日通知をスケジュール
    await _scheduleSalaryNotificationForWorkplace(workplace);
  }

  Future<void> updateWorkplace(WorkplaceModel workplace) async {
    await _firestoreService.updateWorkplace(workplace);
    // 給料日通知を更新
    await _scheduleSalaryNotificationForWorkplace(workplace);
  }

  Future<void> deleteWorkplace(String workplaceId) async {
    await _firestoreService.deleteWorkplace(workplaceId);
    // 給料日通知をキャンセル
    await NotificationService().cancelSalaryNotification(workplaceId);
  }

  // ==================== Shift ====================

  void loadShifts(String userId) {
    _firestoreService.getShifts(userId).listen((shifts) {
      _shifts = shifts;
      notifyListeners();
    });
  }

  Future<void> addShift(ShiftModel shift) async {
    await _firestoreService.addShift(shift);
    // 給料日通知を更新
    print('🔵 シフト追加後の給料日通知更新チェック');
    print('   - workplaceId: ${shift.workplaceId}');
    print('   - _workplaces.length: ${_workplaces.length}');
    if (shift.workplaceId != null && _workplaces.isNotEmpty) {
      try {
        final workplace = _workplaces.firstWhere(
          (w) => w.id == shift.workplaceId,
        );
        print('   - 勤務先が見つかりました: ${workplace.name}');
        await _scheduleSalaryNotificationForWorkplace(workplace);
      } catch (e) {
        print('⚠️ 給料日通知の更新をスキップ: 勤務先が見つかりません ($e)');
      }
    } else {
      print('⚠️ 給料日通知をスキップ: workplaceId=${shift.workplaceId}, workplaces=${_workplaces.length}');
    }
  }

  Future<void> updateShift(ShiftModel shift) async {
    await _firestoreService.updateShift(shift);
    // 給料日通知を更新
    print('🔵 シフト更新後の給料日通知更新チェック');
    print('   - workplaceId: ${shift.workplaceId}');
    print('   - _workplaces.length: ${_workplaces.length}');
    if (shift.workplaceId != null && _workplaces.isNotEmpty) {
      try {
        final workplace = _workplaces.firstWhere(
          (w) => w.id == shift.workplaceId,
        );
        print('   - 勤務先が見つかりました: ${workplace.name}');
        await _scheduleSalaryNotificationForWorkplace(workplace);
      } catch (e) {
        print('⚠️ 給料日通知の更新をスキップ: 勤務先が見つかりません ($e)');
      }
    } else {
      print('⚠️ 給料日通知をスキップ: workplaceId=${shift.workplaceId}, workplaces=${_workplaces.length}');
    }
  }

  Future<void> deleteShift(String shiftId) async {
    // 削除前にシフト情報を取得
    try {
      final shift = _shifts.firstWhere((s) => s.id == shiftId);
      await _firestoreService.deleteShift(shiftId);
      // 給料日通知を更新
      if (shift.workplaceId != null && _workplaces.isNotEmpty) {
        try {
          final workplace = _workplaces.firstWhere(
            (w) => w.id == shift.workplaceId,
          );
          await _scheduleSalaryNotificationForWorkplace(workplace);
        } catch (e) {
          print('⚠️ 給料日通知の更新をスキップ: 勤務先が見つかりません');
        }
      }
    } catch (e) {
      print('⚠️ シフトが見つかりません: $e');
      await _firestoreService.deleteShift(shiftId);
    }
  }

  // ==================== DiaryMemo ====================

  void loadDiaryMemos(String userId) {
    _firestoreService.getDiaryMemos(userId).listen((memos) {
      _diaryMemos = memos;
      notifyListeners();
    });
  }

  Future<void> addDiaryMemo(DiaryMemoModel memo) async {
    print('🔵 DataProvider日記メモ追加開始');
    try {
      await _firestoreService.addDiaryMemo(memo);
      print('✅ DataProvider日記メモ追加成功');
    } catch (e) {
      print('❌ DataProvider日記メモ追加エラー: $e');
      rethrow;
    }
  }

  Future<void> updateDiaryMemo(DiaryMemoModel memo) async {
    await _firestoreService.updateDiaryMemo(memo);
  }

  Future<void> deleteDiaryMemo(String memoId) async {
    await _firestoreService.deleteDiaryMemo(memoId);
  }

  // ==================== Todo ====================

  void loadTodos(String userId) {
    _firestoreService.getTodos(userId).listen((todos) {
      _todos = todos;
      notifyListeners();
    });
  }

  Future<void> addTodo(TodoModel todo) async {
    await _firestoreService.addTodo(todo);
  }

  Future<void> updateTodo(TodoModel todo) async {
    await _firestoreService.updateTodo(todo);
  }

  Future<void> deleteTodo(String todoId) async {
    await _firestoreService.deleteTodo(todoId);
  }

  // ==================== Friendship ====================

  void loadFriendships(String userId) {
    _firestoreService.getFriends(userId).listen((friendships) {
      _friendships = friendships;
      notifyListeners();
      _ensureFriendProfileImages(friendships);
      
      // 友達が追加/削除されたら、友達の公開データを再読み込み
      final friendIds = friendships.map((f) => f.friendId).toList();
      loadFriendsPublicData(friendIds);
    });
  }

  Future<void> addFriend({
    required String userId,
    required String friendId,
    required String friendNickname,
  }) async {
    await _firestoreService.addFriend(
      userId: userId,
      friendId: friendId,
      friendNickname: friendNickname,
    );
  }

  Future<void> updateFriendship(FriendshipModel friendship) async {
    await _firestoreService.updateFriendship(friendship);
  }

  Future<void> deleteFriendship(String friendshipId) async {
    await _firestoreService.deleteFriendship(friendshipId);
  }

  // 友達の公開データを読み込む
  void loadFriendsPublicData(List<String> friendIds) {
    print('🔵 友達の公開データ読み込み開始: friendIds=$friendIds');
    
    // 友達の公開シフト
    _firestoreService.getFriendsPublicShifts(friendIds).listen((shifts) {
      _friendsPublicShifts = shifts;
      notifyListeners();
      print('✅ 友達の公開シフト読み込み完了: ${shifts.length}件');
    });
    
    // 友達の公開日記メモ
    _firestoreService.getFriendsPublicDiaryMemos(friendIds).listen((memos) {
      _friendsPublicDiaryMemos = memos;
      notifyListeners();
      print('✅ 友達の公開日記メモ読み込み完了: ${memos.length}件');
    });
    
    // 友達の公開TODO
    _firestoreService.getFriendsPublicTodos(friendIds).listen((todos) {
      _friendsPublicTodos = todos;
      notifyListeners();
      print('✅ 友達の公開TODO読み込み完了: ${todos.length}件');
    });
  }

  Future<void> _ensureFriendProfileImages(
    List<FriendshipModel> friendships,
  ) async {
    for (final friendship in friendships) {
      final imageUrl = friendship.friendProfileImageUrl;
      if ((imageUrl == null || imageUrl.isEmpty) &&
          !_friendImageSyncInProgress.contains(friendship.friendId)) {
        _friendImageSyncInProgress.add(friendship.friendId);
        try {
          final profileUrl = await _firestoreService
              .getUserProfileImage(friendship.friendId);
          if (profileUrl != null && profileUrl.isNotEmpty) {
            await _firestoreService.setFriendProfileImage(
              friendship.id,
              profileUrl,
            );
          }
        } catch (e) {
          print('友達プロフィール画像同期エラー: $e');
        } finally {
          _friendImageSyncInProgress.remove(friendship.friendId);
        }
      }
    }
  }

  // すべてのデータを読み込む
  void loadAllData(String userId) {
    loadWorkplaces(userId);
    loadShifts(userId);
    loadDiaryMemos(userId);
    loadTodos(userId);
    loadFriendships(userId);
    
    // 友達の公開データも読み込む
    final friendIds = _friendships.map((f) => f.friendId).toList();
    if (friendIds.isNotEmpty) {
      loadFriendsPublicData(friendIds);
    }
    
    // 給料日通知を更新（データ読み込み後に実行）
    Future.delayed(const Duration(seconds: 2), () {
      updateSalaryNotifications();
    });
  }

  // ==================== 給料日通知 ====================

  /// すべての勤務先の給料日通知を更新
  Future<void> updateSalaryNotifications() async {
    print('🔵 給料日通知を更新中...');
    
    for (final workplace in _workplaces) {
      await _scheduleSalaryNotificationForWorkplace(workplace);
    }
    
    print('✅ 給料日通知の更新完了');
  }

  /// 特定の勤務先の給料日通知をスケジュール
  Future<void> _scheduleSalaryNotificationForWorkplace(
    WorkplaceModel workplace,
  ) async {
    print('🔵 給料日通知のスケジュール開始: ${workplace.name}');
    try {
      final now = DateTime.now();
      print('   - 現在日時: $now');
      
      // 次の給料日を計算（未来の最も近い給料日）
      final targetPaymentDate = app_date_utils.DateUtils.calculatePaymentDate(
        baseDate: now,
        closingDay: workplace.closingDay,
        paymentMonth: workplace.paymentMonth,
        paymentDay: workplace.paymentDay,
      );

      // 給料日から対象締日期間を逆算
      // 給料日 = 締日の月 + paymentMonth
      // なので、締日 = 給料日の月 - paymentMonth
      int closingMonth = targetPaymentDate.month - workplace.paymentMonth;
      int closingYear = targetPaymentDate.year;
      while (closingMonth < 1) {
        closingMonth += 12;
        closingYear--;
      }
      
      // 月末締めの場合は、その月の最終日を使用
      final actualClosingDay = workplace.closingDay > 28 
          ? app_date_utils.DateUtils.getLastDayOfMonth(closingYear, closingMonth)
          : workplace.closingDay;
      final closingDate = DateTime(closingYear, closingMonth, actualClosingDay);

      // 前回の締日を計算（前月の締日）
      int previousClosingMonth = closingMonth - 1;
      int previousClosingYear = closingYear;
      if (previousClosingMonth < 1) {
        previousClosingMonth = 12;
        previousClosingYear--;
      }
      final previousActualClosingDay = workplace.closingDay > 28
          ? app_date_utils.DateUtils.getLastDayOfMonth(previousClosingYear, previousClosingMonth)
          : workplace.closingDay;
      final previousClosingDate = DateTime(
        previousClosingYear,
        previousClosingMonth,
        previousActualClosingDay,
      );

      // 締日期間の開始日（前回の締日の翌日）と終了日（今回の締日）
      final periodStart = previousClosingDate.add(const Duration(days: 1));
      final periodEnd = closingDate.add(const Duration(days: 1)); // 締日を含むため翌日を使用

      // 期間内のシフトを取得
      final relevantShifts = _shifts.where((shift) {
        if (shift.workplaceId != workplace.id) return false;
        
        final shiftDate = shift.date;
        return !shiftDate.isBefore(periodStart) && shiftDate.isBefore(periodEnd);
      }).toList();

      // 給料見込み額を計算
      double estimatedSalary = 0.0;
      for (final shift in relevantShifts) {
        estimatedSalary += SalaryCalculator.calculateShiftSalary(
          shift: shift,
          workplace: workplace,
        );
      }

      print('💰 勤務先: ${workplace.name}');
      print('   - 給料日: $targetPaymentDate');
      print('   - 対象期間: $periodStart 〜 $closingDate');
      print('   - 見込み額: ¥${estimatedSalary.toInt()}');
      print('   - 対象シフト: ${relevantShifts.length}件');

      // 通知をスケジュール
      await NotificationService().scheduleSalaryNotification(
        workplaceId: workplace.id,
        paymentDate: targetPaymentDate,
        workplaceName: workplace.name,
        estimatedSalary: estimatedSalary.toInt(),
      );
    } catch (e, stackTrace) {
      print('⚠️ 給料日通知のスケジュールに失敗: $e');
      print('   スタックトレース: $stackTrace');
    }
  }
}
