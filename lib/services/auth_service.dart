import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;

  // 認証状態のストリーム
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 匿名ログイン
  Future<UserCredential> signInAnonymously() async {
    print('🔵 匿名ログイン実行中...');
    final result = await _auth.signInAnonymously();
    print('✅ 匿名ログイン成功: uid=${result.user?.uid}');
    print('📊 Firebase Auth ユーザー: ${result.user?.toString()}');
    return result;
  }

  // ユーザー情報を作成
  Future<void> createUserProfile({
    required String uid,
    String? nickname,
    required bool acceptedTerms,
    required bool acceptedPrivacyPolicy,
  }) async {
    final qrCode = _uuid.v4();
    final userModel = UserModel(
      uid: uid,
      nickname: nickname,
      qrCode: qrCode,
      createdAt: DateTime.now(),
      acceptedTerms: acceptedTerms,
      acceptedPrivacyPolicy: acceptedPrivacyPolicy,
    );

    print('🔵 ユーザープロフィール作成: uid=$uid, nickname=$nickname');
    await _firestore.collection('users').doc(uid).set(userModel.toMap());
    print('✅ Firestoreに保存完了');
  }

  // ユーザー情報を取得
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // ユーザー情報を更新
  Future<void> updateUserProfile({
    required String uid,
    String? nickname,
    String? profileImageUrl,
  }) async {
    final updateData = <String, dynamic>{};
    if (nickname != null) updateData['nickname'] = nickname;
    if (profileImageUrl != null)
      updateData['profileImageUrl'] = profileImageUrl;

    await _firestore.collection('users').doc(uid).update(updateData);
  }

  Future<void> removeProfileImage(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'profileImageUrl': FieldValue.delete(),
    });
  }

  // ログアウト
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // =========================
  // メール/パスワード認証
  // =========================

  /// メールアドレスとパスワードでサインアップ
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    print('🔵 メールアドレスでサインアップ: $email');
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('✅ サインアップ成功: uid=${result.user?.uid}');
    
    // メール確認を送信
    await result.user?.sendEmailVerification();
    print('📧 確認メールを送信しました');
    
    return result;
  }

  /// メールアドレスとパスワードでログイン
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    print('🔵 メールアドレスでログイン: $email');
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('✅ ログイン成功: uid=${result.user?.uid}');
    return result;
  }

  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail(String email) async {
    print('🔵 パスワードリセットメール送信: $email');
    await _auth.sendPasswordResetEmail(email: email);
    print('📧 パスワードリセットメールを送信しました');
  }

  /// メール確認済みかチェック
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// 確認メールを再送信
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
    print('📧 確認メールを再送信しました');
  }

  // =========================
  // 匿名アカウントのリンク
  // =========================

  /// 現在の匿名アカウントにメール/パスワードをリンク
  Future<UserCredential> linkAnonymousAccountWithEmail({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      throw Exception('匿名ユーザーでログインしていません');
    }

    print('🔵 匿名アカウントにメール/パスワードをリンク: $email');
    
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    final result = await user.linkWithCredential(credential);
    print('✅ リンク成功: uid=${result.user?.uid}');
    
    // メール確認を送信
    await result.user?.sendEmailVerification();
    print('📧 確認メールを送信しました');
    
    return result;
  }

  /// 現在のユーザーが匿名ユーザーかチェック
  bool isAnonymousUser() {
    return _auth.currentUser?.isAnonymous ?? false;
  }

  /// ユーザーがどの認証方法を使っているか取得
  List<String> getSignInMethods() {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    return user.providerData.map((info) => info.providerId).toList();
  }
}
