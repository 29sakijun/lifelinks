import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import 'email_sign_in_screen.dart';
import 'email_sign_up_screen.dart';
import '../home/calendar_screen.dart';
import '../onboarding/nickname_screen.dart';

/// 認証方法選択画面
class AuthSelectionScreen extends StatefulWidget {
  final bool isLinkMode; // 匿名アカウントをリンクするモードか

  const AuthSelectionScreen({
    super.key,
    this.isLinkMode = false,
  });

  @override
  State<AuthSelectionScreen> createState() => _AuthSelectionScreenState();
}

class _AuthSelectionScreenState extends State<AuthSelectionScreen> {
  bool _isLoading = false;

  /// Googleサインイン処理
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authService = authProvider.authService;

      UserCredential? result;

      if (widget.isLinkMode && authService.isAnonymousUser()) {
        // 匿名アカウントにGoogleをリンク
        result = await authService.linkAnonymousAccountWithGoogle();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Googleアカウントをリンクしました')),
          );
          Navigator.of(context).pop(); // 設定画面に戻る
        }
      } else {
        // 新規Googleサインイン
        result = await authService.signInWithGoogle();
        
        // ユーザープロフィールをチェック
        final userProfile = await authService.getUserProfile(result.user!.uid);
        
        if (mounted) {
          if (userProfile == null) {
            // 新規ユーザー → ニックネーム登録画面へ
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => NicknameScreen(uid: result.user!.uid),
              ),
            );
          } else {
            // 既存ユーザー → ホーム画面へ
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Googleサインインエラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Googleサインインに失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Appleサインイン処理
  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authService = authProvider.authService;

      UserCredential? result;

      if (widget.isLinkMode && authService.isAnonymousUser()) {
        // 匿名アカウントにAppleをリンク
        result = await authService.linkAnonymousAccountWithApple();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appleアカウントをリンクしました')),
          );
          Navigator.of(context).pop(); // 設定画面に戻る
        }
      } else {
        // 新規Appleサインイン
        result = await authService.signInWithApple();
        
        // ユーザープロフィールをチェック
        final userProfile = await authService.getUserProfile(result.user!.uid);
        
        if (mounted) {
          if (userProfile == null) {
            // 新規ユーザー → ニックネーム登録画面へ
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => NicknameScreen(uid: result.user!.uid),
              ),
            );
          } else {
            // 既存ユーザー → ホーム画面へ
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Appleサインインエラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appleサインインに失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isLinkMode ? 'アカウントをリンク' : 'ログイン / サインアップ'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // ロゴ
                    Center(
                      child: Image.asset(
                        'assets/images/lifelink_logo.png',
                        height: 100,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // タイトル
                    Text(
                      'LifeLink',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // サブタイトル
                    Text(
                      widget.isLinkMode
                          ? '認証方法を選択してリンクしてください'
                          : 'あなたの生活を友達とつなぐ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Appleサインインボタン（iOSのみ）
                    if (Platform.isIOS)
                      _buildAppleSignInButton(),
                    
                    if (Platform.isIOS)
                      const SizedBox(height: 16),
                    
                    // Googleサインインボタン
                    _buildGoogleSignInButton(),
                    
                    const SizedBox(height: 16),
                    
                    // メール/パスワードボタン
                    _buildEmailSignInButton(),
                    
                    const SizedBox(height: 32),
                    
                    // 区切り線
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            widget.isLinkMode ? '' : 'または',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // サインアップボタン（リンクモードでない場合のみ）
                    if (!widget.isLinkMode)
                      _buildSignUpButton(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  /// Appleサインインボタン
  Widget _buildAppleSignInButton() {
    return ElevatedButton.icon(
      onPressed: _handleAppleSignIn,
      icon: const Icon(Icons.apple, color: Colors.white),
      label: Text(
        widget.isLinkMode ? 'Appleアカウントをリンク' : 'Appleでサインイン',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }

  /// Googleサインインボタン
  Widget _buildGoogleSignInButton() {
    return OutlinedButton.icon(
      onPressed: _handleGoogleSignIn,
      icon: Image.asset(
        'assets/images/lifelink_icon.png', // Google iconの代わりにアプリアイコン
        height: 20,
      ),
      label: Text(
        widget.isLinkMode ? 'Googleアカウントをリンク' : 'Googleでサインイン',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  /// メール/パスワードサインインボタン
  Widget _buildEmailSignInButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EmailSignInScreen(isLinkMode: widget.isLinkMode),
          ),
        );
      },
      icon: const Icon(Icons.email, color: Colors.white),
      label: Text(
        widget.isLinkMode ? 'メールアドレスをリンク' : 'メールアドレスでログイン',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }

  /// サインアップボタン
  Widget _buildSignUpButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const EmailSignUpScreen(),
          ),
        );
      },
      child: RichText(
        text: TextSpan(
          text: 'アカウントをお持ちでない方は ',
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
          children: [
            TextSpan(
              text: '新規登録',
              style: TextStyle(
                color: Colors.purple[700],
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

