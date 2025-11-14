import 'package:flutter/material.dart';
import 'email_sign_in_screen.dart';
import 'email_sign_up_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isLinkMode ? 'アカウントをリンク' : 'ログイン / サインアップ'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
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
                    
                    // メールログインボタン
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
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
                      ),
                    ),
                    
                    // 新規登録ボタン（リンクモードでない場合のみ）
                    if (!widget.isLinkMode) ...[
                      const SizedBox(height: 32),
                      
                      // 区切り線
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'または',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // サインアップボタン
                      TextButton(
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
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

