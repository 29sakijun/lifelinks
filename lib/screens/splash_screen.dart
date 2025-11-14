import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import 'onboarding/terms_screen.dart';
import 'home/calendar_screen.dart';
import 'auth/auth_welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // 認証状態の初期化を待つ
    await Future.delayed(const Duration(milliseconds: 500));

    print('🔵 認証状態確認: ${authProvider.isAuthenticated}');
    print('🔵 現在のユーザー: ${authProvider.user?.uid}');

    if (authProvider.isAuthenticated && authProvider.user != null) {
      print('🔵 認証済みユーザー: ${authProvider.user?.uid}');

      // プロフィールを明示的に読み込む
      await authProvider.loadUserProfile();

      print('🔵 プロフィール: ${authProvider.userProfile?.nickname ?? "なし"}');

      if (!mounted) return;

      // ユーザープロフィールが存在するか確認
      if (authProvider.userProfile != null && authProvider.user != null) {
        // データを読み込む
        dataProvider.loadAllData(authProvider.user!.uid);

        print('✅ カレンダー画面へ遷移');
        // カレンダー画面へ
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        );
      } else {
        print('⚠️ プロフィールが見つかりません - 初回登録画面へ');
        // 初回登録画面へ
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TermsScreen()),
        );
      }
    } else {
      print('🔵 未認証 - 認証選択画面へ');
      // 認証選択画面へ（匿名ログイン or ログイン/サインアップ）
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A148C), // 濃い紫
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // カスタム画像を使用（大きく表示）
            Image.asset(
              'assets/images/lifelink_logo.png',
              width: 200,
              height: 200,
            ),
            // Icon(Icons.people, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'LifeLink',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect your life with friends',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
