import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/terms_screen.dart';
import 'auth_selection_screen.dart';

/// 認証ウェルカム画面（匿名 or ログイン/サインアップ）
class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  /// 匿名で始める
  Future<void> _startAnonymously(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // ローディング表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      await authProvider.signInAnonymously();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // ローディングを閉じる
        
        // 初回登録画面へ
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TermsScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // ローディングを閉じる
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // ロゴ
              Image.asset(
                'assets/images/lifelink_logo.png',
                height: 120,
              ),
              
              const SizedBox(height: 24),
              
              // タイトル
              Text(
                'LifeLink',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // サブタイトル
              Text(
                'あなたの生活を友達とつなぐ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 説明
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'シフト・日記・TODOを\n友達と共有しよう',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // ログイン/サインアップボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AuthSelectionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'ログイン / サインアップ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 匿名で始めるボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _startAnonymously(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.purple[700]!, width: 2),
                  ),
                  child: const Text(
                    'まずは試しに使ってみる（匿名）',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 説明テキスト
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '匿名で始めても、後からアカウントを作成してデータを保存できます',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.4,
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

