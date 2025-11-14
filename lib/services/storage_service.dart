import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // 画像をアップロード
  Future<String> uploadImage({
    required String userId,
    required File imageFile,
    required String folder, // 'diary_memos' など
  }) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('users/$userId/$folder/$fileName');

    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  // プロフィール画像をアップロード
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      print('🔵 StorageService: プロフィール画像アップロード開始');
      print('  userId: $userId');
      print('  imageFile: ${imageFile.path}');
      print('  imageFile.exists: ${await imageFile.exists()}');
      
      // 認証状態を確認
      final currentUser = _auth.currentUser;
      print('  Firebase Auth currentUser: ${currentUser?.uid}');
      print('  Firebase Auth isAuthenticated: ${currentUser != null}');
      if (currentUser == null) {
        throw Exception('ユーザーが認証されていません');
      }
      if (currentUser.uid != userId) {
        throw Exception('ユーザーIDが一致しません: ${currentUser.uid} != $userId');
      }
      
      final fileName = 'profile.jpg';
      final ref = _storage.ref().child('users/$userId/profile/$fileName');
      print('  ref path: ${ref.fullPath}');

      print('🔵 アップロード開始...');
      final uploadTask = ref.putFile(imageFile);
      
      print('🔵 アップロード完了待機...');
      final snapshot = await uploadTask.whenComplete(() {
        print('✅ アップロード完了');
      });
      
      print('🔵 ダウンロードURL取得...');
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ ダウンロードURL取得成功: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      print('❌ StorageService: プロフィール画像アップロードエラー');
      print('  エラー: $e');
      print('  スタックトレース: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteProfileImage({required String userId}) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile/profile.jpg');
      print('🔵 StorageService: プロフィール画像削除開始 path=${ref.fullPath}');
      await ref.delete();
      print('✅ StorageService: プロフィール画像削除完了');
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('ℹ️ プロフィール画像は既に存在しません');
        return;
      }
      print('❌ StorageService: プロフィール画像削除エラー $e');
      rethrow;
    }
  }

  // 画像を削除
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // 画像が存在しない場合などのエラーを無視
      print('画像削除エラー: $e');
    }
  }

  // 複数の画像を削除
  Future<void> deleteImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteImage(url);
    }
  }
}
