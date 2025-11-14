import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  AuthService get authService => _authService; // AuthServiceへのアクセスを提供

  AuthProvider() {
    // 初期認証状態を設定
    _user = _authService.currentUser;

    // 認証状態の監視
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        await loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  // ユーザープロフィールを読み込む
  Future<void> loadUserProfile() async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = await _authService.getUserProfile(_user!.uid);
    } catch (e) {
      print('プロフィール読み込みエラー: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 匿名ログイン
  Future<void> signInAnonymously() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInAnonymously();
    } catch (e) {
      print('匿名ログインエラー: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ユーザープロフィールを作成
  Future<void> createUserProfile({
    String? nickname,
    required bool acceptedTerms,
    required bool acceptedPrivacyPolicy,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.createUserProfile(
        uid: _user!.uid,
        nickname: nickname,
        acceptedTerms: acceptedTerms,
        acceptedPrivacyPolicy: acceptedPrivacyPolicy,
      );
      await loadUserProfile();
    } catch (e) {
      print('プロフィール作成エラー: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ニックネームを更新
  Future<void> updateNickname(String nickname) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(uid: _user!.uid, nickname: nickname);
      await loadUserProfile();
    } catch (e) {
      print('ニックネーム更新エラー: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // プロフィール画像を更新
  Future<void> updateProfileImage(String imageUrl) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(
        uid: _user!.uid,
        profileImageUrl: imageUrl,
      );
      await loadUserProfile();

      // 友達のプロフィール画像情報も更新
      try {
        await _firestoreService.updateFriendProfileImage(_user!.uid, imageUrl);
      } catch (e) {
        print('友達プロフィール画像同期エラー: $e');
      }
    } catch (e) {
      print('プロフィール画像更新エラー: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearProfileImage() async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.removeProfileImage(_user!.uid);
      await loadUserProfile();

      try {
        await _firestoreService.updateFriendProfileImage(_user!.uid, null);
      } catch (e) {
        print('友達プロフィール画像削除同期エラー: $e');
      }
    } catch (e) {
      print('プロフィール画像削除エラー: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ログアウト
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }
}
