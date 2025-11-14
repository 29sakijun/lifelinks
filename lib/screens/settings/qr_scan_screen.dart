import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  Future<void> _onDetect(String code) async {
    if (_isProcessing) return;
    if (code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      // 自分のQRコードでないか確認
      if (code == authProvider.userProfile?.qrCode) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('自分のQRコードです')));
        Navigator.pop(context);
        return;
      }

      // QRコードからユーザーを検索
      final userDoc = await _firestoreService.findUserByQrCode(code);

      if (userDoc == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ユーザーが見つかりませんでした')));
        Navigator.pop(context);
        return;
      }

      final friendUser = UserModel.fromFirestore(userDoc);

      // すでに友達かチェック
      final alreadyFriend = dataProvider.friendships.any(
        (f) => f.friendId == friendUser.uid,
      );

      if (alreadyFriend) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('すでに友達です')));
        Navigator.pop(context);
        return;
      }

      // 友達を追加
      await dataProvider.addFriend(
        userId: authProvider.user!.uid,
        friendId: friendUser.uid,
        friendNickname: friendUser.displayName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${friendUser.displayName}を友達に追加しました')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QRコードをスキャン')),
      body: AiBarcodeScanner(
        onDetect: (BarcodeCapture capture) {
          final String? code = capture.barcodes.firstOrNull?.rawValue;
          if (code != null) {
            _onDetect(code);
          }
        },
      ),
    );
  }
}
