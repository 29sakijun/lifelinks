import 'package:flutter/material.dart';
import 'email_sign_in_screen.dart';
import 'email_sign_up_screen.dart';

/// 認証方法選択画面
class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A148C), // 濃い紫背景
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // ロゴ
              Center(
                child: Image.asset(
                  'assets/images/lifelink_logo.png',
                  height: 120,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // タイトル
              const Text(
                'LifeLink',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // サブタイトル
              Text(
                'あなたの生活を友達とつなぐ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              
              const SizedBox(height: 80),
              
              // メールログインボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EmailSignInScreen(isLinkMode: false),
                      ),
                    );
                  },
                  icon: Icon(Icons.email, color: Colors.purple[700]),
                  label: Text(
                    'メールアドレスでログイン',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple[700],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 区切り線
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'または',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
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
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    children: const [
                      TextSpan(
                        text: '新規登録',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

