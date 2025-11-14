import 'package:flutter/foundation.dart';
import '../models/workplace_model.dart';
import '../models/shift_model.dart';
import '../models/diary_memo_model.dart';
import '../models/todo_model.dart';
import '../models/friendship_model.dart';
import '../services/firestore_service.dart';

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
  }

  Future<void> updateWorkplace(WorkplaceModel workplace) async {
    await _firestoreService.updateWorkplace(workplace);
  }

  Future<void> deleteWorkplace(String workplaceId) async {
    await _firestoreService.deleteWorkplace(workplaceId);
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
  }

  Future<void> updateShift(ShiftModel shift) async {
    await _firestoreService.updateShift(shift);
  }

  Future<void> deleteShift(String shiftId) async {
    await _firestoreService.deleteShift(shiftId);
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
  }
}
