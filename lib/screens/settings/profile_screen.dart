import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../services/storage_service.dart';
import 'qr_scan_screen.dart';
import '../auth/auth_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  bool _isEditing = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nicknameController.text = authProvider.userProfile?.nickname ?? '';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('画像の選択に失敗しました: $e')));
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('写真の撮影に失敗しました: $e')));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ユーザーが認証されていません')));
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      print('🔵 プロフィール画像アップロード開始: userId=${authProvider.user!.uid}');

      // プロフィール画像をアップロード
      final imageUrl = await _storageService.uploadProfileImage(
        userId: authProvider.user!.uid,
        imageFile: imageFile,
      );

      print('✅ プロフィール画像アップロード成功: imageUrl=$imageUrl');

      // プロフィール情報を更新
      print('🔵 プロフィール情報更新開始');
      await authProvider.updateProfileImage(imageUrl);
      print('✅ プロフィール情報更新成功');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('プロフィール画像を更新しました')));
    } catch (e, stackTrace) {
      print('❌ プロフィール画像アップロードエラー: $e');
      print('スタックトレース: $stackTrace');

      if (!mounted) return;

      String errorMessage = '画像のアップロードに失敗しました';
      if (e.toString().contains('permission')) {
        errorMessage = '画像のアップロード権限がありません';
      } else if (e.toString().contains('network')) {
        errorMessage = 'ネットワークエラーが発生しました';
      } else if (e.toString().isNotEmpty) {
        errorMessage = 'エラー: $e';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _showImagePicker() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final hasImage = authProvider.userProfile?.profileImageUrl != null;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('画像を削除'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmRemoveImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNickname() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.updateNickname(_nicknameController.text);

      if (!mounted) return;
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ニックネームを更新しました')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }

  Future<void> _confirmRemoveImage() async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('画像を削除'),
        content: const Text('プロフィール画像を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      await _removeImage();
    }
  }

  Future<void> _removeImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null ||
        authProvider.userProfile?.profileImageUrl == null) {
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      await _storageService.deleteProfileImage(userId: authProvider.user!.uid);
    } catch (e) {
      print('プロフィール画像の削除時にエラー（Storage）: $e');
    }

    try {
      await authProvider.clearProfileImage();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('プロフィール画像を削除しました')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('プロフィール画像削除に失敗しました: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('マイプロフィール')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      authProvider.userProfile?.profileImageUrl != null
                      ? NetworkImage(authProvider.userProfile!.profileImageUrl!)
                      : null,
                  child: authProvider.userProfile?.profileImageUrl == null
                      ? Text(
                          authProvider.userProfile?.displayName[0] ?? '?',
                          style: const TextStyle(fontSize: 40),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: _isUploadingImage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                      onPressed: _isUploadingImage ? null : _showImagePicker,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isEditing)
              Column(
                children: [
                  TextField(
                    controller: _nicknameController,
                    maxLength: AppConstants.maxNicknameLength,
                    decoration: const InputDecoration(
                      labelText: 'ニックネーム',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _nicknameController.text =
                                  authProvider.userProfile?.nickname ?? '';
                            });
                          },
                          child: const Text('キャンセル'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveNickname,
                          child: const Text('保存'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    authProvider.userProfile?.displayName ?? '秘密',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  // デバッグ用：UID表示
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ユーザーID (Firebase Authentication)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          authProvider.user?.uid ?? 'なし',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('編集'),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text('友達追加用QRコード', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: QrImageView(
                data: authProvider.userProfile?.qrCode ?? '',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'このQRコードを友達に読み取ってもらうことで、友達を追加できます',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QRScanScreen()),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('友達のQRコードを読み取る'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            // 匿名ユーザーの場合、アカウントリンクセクションを表示
            if (authProvider.authService.isAnonymousUser()) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[700],
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '匿名アカウントで利用中',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'アカウントをリンクすると、データを永続的に保存し、\n複数のデバイスで利用できます',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[800],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AuthSelectionScreen(isLinkMode: true),
                      ),
                    );
                  },
                  icon: const Icon(Icons.link),
                  label: const Text('アカウントをリンクする'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
