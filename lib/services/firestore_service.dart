import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workplace_model.dart';
import '../models/shift_model.dart';
import '../models/diary_memo_model.dart';
import '../models/todo_model.dart';
import '../models/friendship_model.dart';
import '../models/reaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Workplace ====================

  // 勤務先を追加
  Future<String> addWorkplace(WorkplaceModel workplace) async {
    final doc = await _firestore
        .collection('workplaces')
        .add(workplace.toMap());
    return doc.id;
  }

  // 勤務先を更新
  Future<void> updateWorkplace(WorkplaceModel workplace) async {
    await _firestore
        .collection('workplaces')
        .doc(workplace.id)
        .update(workplace.toMap());
  }

  // 勤務先を削除
  Future<void> deleteWorkplace(String workplaceId) async {
    await _firestore.collection('workplaces').doc(workplaceId).delete();
  }

  // ユーザーの勤務先一覧を取得
  Stream<List<WorkplaceModel>> getWorkplaces(String userId) {
    return _firestore
        .collection('workplaces')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkplaceModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== Shift ====================

  // シフトを追加
  Future<String> addShift(ShiftModel shift) async {
    final doc = await _firestore.collection('shifts').add(shift.toMap());
    return doc.id;
  }

  // シフトを更新
  Future<void> updateShift(ShiftModel shift) async {
    await _firestore.collection('shifts').doc(shift.id).update(shift.toMap());
  }

  // シフトを削除
  Future<void> deleteShift(String shiftId) async {
    await _firestore.collection('shifts').doc(shiftId).delete();
  }

  // ユーザーのシフト一覧を取得
  Stream<List<ShiftModel>> getShifts(String userId) {
    return _firestore
        .collection('shifts')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ShiftModel.fromFirestore(doc))
              .toList(),
        );
  }

  // 特定の日付範囲のシフトを取得
  Stream<List<ShiftModel>> getShiftsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('shifts')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ShiftModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== DiaryMemo ====================

  // 日記メモを追加
  Future<String> addDiaryMemo(DiaryMemoModel memo) async {
    print(
      '🔵 Firestore日記メモ追加開始: userId=${memo.userId}, isPublic=${memo.isPublic}',
    );
    try {
      final doc = await _firestore.collection('diaryMemos').add(memo.toMap());
      print('✅ Firestore日記メモ追加成功: docId=${doc.id}');
      return doc.id;
    } catch (e) {
      print('❌ Firestore日記メモ追加エラー: $e');
      rethrow;
    }
  }

  // 日記メモを更新
  Future<void> updateDiaryMemo(DiaryMemoModel memo) async {
    await _firestore.collection('diaryMemos').doc(memo.id).update(memo.toMap());
  }

  // 日記メモを削除
  Future<void> deleteDiaryMemo(String memoId) async {
    await _firestore.collection('diaryMemos').doc(memoId).delete();
  }

  // ユーザーの日記メモ一覧を取得
  Stream<List<DiaryMemoModel>> getDiaryMemos(String userId) {
    return _firestore
        .collection('diaryMemos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DiaryMemoModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== Todo ====================

  // TODOを追加
  Future<String> addTodo(TodoModel todo) async {
    final doc = await _firestore.collection('todos').add(todo.toMap());
    return doc.id;
  }

  // TODOを更新
  Future<void> updateTodo(TodoModel todo) async {
    await _firestore.collection('todos').doc(todo.id).update(todo.toMap());
  }

  // TODOを削除
  Future<void> deleteTodo(String todoId) async {
    await _firestore.collection('todos').doc(todoId).delete();
  }

  // ユーザーのTODO一覧を取得
  Stream<List<TodoModel>> getTodos(String userId) {
    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TodoModel.fromFirestore(doc)).toList(),
        );
  }

  // ==================== Friendship ====================

  // 友達を追加（双方向）
  Future<void> addFriend({
    required String userId,
    required String friendId,
    required String friendNickname,
  }) async {
    print('🔵 双方向友達追加開始: userId=$userId, friendId=$friendId');

    // 友達のプロフィール情報を取得
    final friendDoc = await _firestore.collection('users').doc(friendId).get();
    final friendData = friendDoc.data();
    final myNickname = friendData?['nickname'] ?? '秘密';
    final friendProfileImageUrl = friendData?['profileImageUrl'];

    // 自分の友達リストに追加（友達のニックネームとプロフィール画像で）
    final myFriendship = FriendshipModel(
      id: '',
      userId: userId,
      friendId: friendId,
      friendNickname: friendNickname,
      friendProfileImageUrl: friendProfileImageUrl,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('friendships').add(myFriendship.toMap());
    print('✅ 自分の友達リストに追加完了');

    // 自分のプロフィール情報を取得
    final myDoc = await _firestore.collection('users').doc(userId).get();
    final myData = myDoc.data();
    final myProfileImageUrl = myData?['profileImageUrl'];

    // 友達の友達リストに追加（自分のニックネームとプロフィール画像で）
    final friendFriendship = FriendshipModel(
      id: '',
      userId: friendId,
      friendId: userId,
      friendNickname: myNickname,
      friendProfileImageUrl: myProfileImageUrl,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('friendships').add(friendFriendship.toMap());
    print('✅ 友達の友達リストに追加完了');
  }

  // 友達設定を更新
  Future<void> updateFriendship(FriendshipModel friendship) async {
    await _firestore
        .collection('friendships')
        .doc(friendship.id)
        .update(friendship.toMap());
  }

  // 友達のプロフィール画像情報を更新
  Future<void> updateFriendProfileImage(
    String userId,
    String? profileImageUrl,
  ) async {
    print('🔵 友達のプロフィール画像情報更新開始: userId=$userId');

    // このユーザーを友達として持っているすべての友達関係を更新
    final friendshipsQuery = await _firestore
        .collection('friendships')
        .where('friendId', isEqualTo: userId)
        .get();

    for (final doc in friendshipsQuery.docs) {
      await _firestore.collection('friendships').doc(doc.id).update({
        'friendProfileImageUrl': profileImageUrl,
      });
    }

    print('✅ 友達のプロフィール画像情報更新完了: ${friendshipsQuery.docs.length}件');
  }

  // 友達を削除
  Future<void> deleteFriendship(String friendshipId) async {
    await _firestore.collection('friendships').doc(friendshipId).delete();
  }

  Future<String?> getUserProfileImage(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    return data?['profileImageUrl'];
  }

  Future<void> setFriendProfileImage(
    String friendshipId,
    String? imageUrl,
  ) async {
    await _firestore.collection('friendships').doc(friendshipId).update({
      'friendProfileImageUrl': imageUrl,
    });
  }

  // ユーザーの友達一覧を取得
  Stream<List<FriendshipModel>> getFriends(String userId) {
    return _firestore
        .collection('friendships')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendshipModel.fromFirestore(doc))
              .toList(),
        );
  }

  // QRコードからユーザーを検索
  Future<DocumentSnapshot?> findUserByQrCode(String qrCode) async {
    final query = await _firestore
        .collection('users')
        .where('qrCode', isEqualTo: qrCode)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first;
    }
    return null;
  }

  // ==================== 友達の公開データ取得 ====================

  // 友達の公開シフトを取得
  Stream<List<ShiftModel>> getFriendsPublicShifts(List<String> friendIds) {
    if (friendIds.isEmpty) {
      return Stream.value([]);
    }

    print('🔵 友達の公開シフト取得: friendIds=$friendIds');

    return _firestore
        .collection('shifts')
        .where('userId', whereIn: friendIds)
        .where('isPublic', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📊 友達の公開シフト取得結果: ${snapshot.docs.length}件');
          return snapshot.docs
              .map((doc) => ShiftModel.fromFirestore(doc))
              .toList();
        });
  }

  // 友達の公開日記メモを取得
  Stream<List<DiaryMemoModel>> getFriendsPublicDiaryMemos(
    List<String> friendIds,
  ) {
    if (friendIds.isEmpty) {
      return Stream.value([]);
    }

    print('🔵 友達の公開日記メモ取得: friendIds=$friendIds');

    return _firestore
        .collection('diaryMemos')
        .where('userId', whereIn: friendIds)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📊 友達の公開日記メモ取得結果: ${snapshot.docs.length}件');
          return snapshot.docs
              .map((doc) => DiaryMemoModel.fromFirestore(doc))
              .toList();
        });
  }

  // 友達の公開TODOを取得
  Stream<List<TodoModel>> getFriendsPublicTodos(List<String> friendIds) {
    if (friendIds.isEmpty) {
      return Stream.value([]);
    }

    print('🔵 友達の公開TODO取得: friendIds=$friendIds');

    return _firestore
        .collection('todos')
        .where('userId', whereIn: friendIds)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📊 友達の公開TODO取得結果: ${snapshot.docs.length}件');
          return snapshot.docs
              .map((doc) => TodoModel.fromFirestore(doc))
              .toList();
        });
  }

  // ==================== Reaction ====================

  // リアクションを追加または更新
  Future<void> addOrUpdateReaction(ReactionModel reaction) async {
    print(
      '🔵 リアクション追加/更新: targetId=${reaction.targetId}, reaction=${reaction.reaction}',
    );

    // 既存のリアクションを確認
    final existingQuery = await _firestore
        .collection('reactions')
        .where('userId', isEqualTo: reaction.userId)
        .where('targetId', isEqualTo: reaction.targetId)
        .limit(1)
        .get();

    if (existingQuery.docs.isNotEmpty) {
      // 既存のリアクションを更新
      final docId = existingQuery.docs.first.id;
      await _firestore
          .collection('reactions')
          .doc(docId)
          .update(reaction.toMap());
      print('✅ リアクション更新完了: docId=$docId');
    } else {
      // 新しいリアクションを追加
      await _firestore.collection('reactions').add(reaction.toMap());
      print('✅ リアクション追加完了');
    }
  }

  // リアクションを削除
  Future<void> deleteReaction(String userId, String targetId) async {
    print('🔵 リアクション削除: userId=$userId, targetId=$targetId');

    final query = await _firestore
        .collection('reactions')
        .where('userId', isEqualTo: userId)
        .where('targetId', isEqualTo: targetId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await _firestore
          .collection('reactions')
          .doc(query.docs.first.id)
          .delete();
      print('✅ リアクション削除完了');
    }
  }

  // 特定の日記メモのリアクションを取得
  Stream<List<ReactionModel>> getReactions(String targetId) {
    return _firestore
        .collection('reactions')
        .where('targetId', isEqualTo: targetId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReactionModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ユーザーの特定の日記メモに対するリアクションを取得
  Future<ReactionModel?> getUserReaction(String userId, String targetId) async {
    final query = await _firestore
        .collection('reactions')
        .where('userId', isEqualTo: userId)
        .where('targetId', isEqualTo: targetId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return ReactionModel.fromFirestore(query.docs.first);
    }
    return null;
  }
}
