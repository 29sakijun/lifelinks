import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../constants/app_constants.dart';
import '../home/calendar_screen.dart';

class NicknameScreen extends StatefulWidget {
  final bool acceptedTerms;
  final bool acceptedPrivacy;

  const NicknameScreen({
    super.key,
    required this.acceptedTerms,
    required this.acceptedPrivacy,
  });

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _createProfile({String? nickname}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      await authProvider.createUserProfile(
        nickname: nickname?.isEmpty ?? true ? null : nickname,
        acceptedTerms: widget.acceptedTerms,
        acceptedPrivacyPolicy: widget.acceptedPrivacy,
      );

      // ユーザーデータの読み込み
      if (authProvider.user != null) {
        dataProvider.loadAllData(authProvider.user!.uid);
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CalendarScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ニックネーム登録')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '公開時のニックネームを設定できます',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'スキップした場合、投稿者名は「秘密」と表示されます',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nicknameController,
              maxLength: AppConstants.maxNicknameLength,
              decoration: InputDecoration(
                labelText: 'ニックネーム',
                hintText: '例：太郎',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _createProfile(nickname: _nicknameController.text),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('登録'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : () => _createProfile(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('スキップ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}















