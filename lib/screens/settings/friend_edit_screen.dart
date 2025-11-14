import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/friendship_model.dart';
import '../../constants/app_constants.dart';

class FriendEditScreen extends StatefulWidget {
  final FriendshipModel friendship;

  const FriendEditScreen({super.key, required this.friendship});

  @override
  State<FriendEditScreen> createState() => _FriendEditScreenState();
}

class _FriendEditScreenState extends State<FriendEditScreen> {
  late Color _selectedColor;
  late bool _shareDiaryMemo;
  late bool _shareTodo;
  late bool _shareShift;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.friendship.friendColor;
    _shareDiaryMemo = widget.friendship.shareDiaryMemo;
    _shareTodo = widget.friendship.shareTodo;
    _shareShift = widget.friendship.shareShift;
  }

  Future<void> _saveFriendship() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final updatedFriendship = widget.friendship.copyWith(
      friendColor: _selectedColor,
      shareDiaryMemo: _shareDiaryMemo,
      shareTodo: _shareTodo,
      shareShift: _shareShift,
    );

    try {
      await dataProvider.updateFriendship(updatedFriendship);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('設定を更新しました')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }

  Future<void> _deleteFriendship() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('友達削除'),
        content: Text('${widget.friendship.friendNickname}を友達から削除しますか？'),
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

    if (confirmed == true) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      await dataProvider.deleteFriendship(widget.friendship.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendship.friendNickname),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteFriendship,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: widget.friendship.friendProfileImageUrl == null
                    ? _selectedColor
                    : Colors.transparent,
                backgroundImage: widget.friendship.friendProfileImageUrl != null
                    ? NetworkImage(widget.friendship.friendProfileImageUrl!)
                    : null,
                child: widget.friendship.friendProfileImageUrl == null
                    ? Text(
                        widget.friendship.friendNickname.isNotEmpty
                            ? widget.friendship.friendNickname[0]
                            : '?',
                        style: const TextStyle(fontSize: 40, color: Colors.white),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text('カラー設定', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.friendColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text('公開設定', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'この友達に公開する情報を選択してください',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('日記メモ'),
              subtitle: const Text('公開フラグがついた日記メモを共有'),
              value: _shareDiaryMemo,
              onChanged: (value) {
                setState(() {
                  _shareDiaryMemo = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('TODO'),
              subtitle: const Text('公開フラグがついたTODOを共有'),
              value: _shareTodo,
              onChanged: (value) {
                setState(() {
                  _shareTodo = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('シフト'),
              subtitle: const Text('公開フラグがついたシフトを共有'),
              value: _shareShift,
              onChanged: (value) {
                setState(() {
                  _shareShift = value;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveFriendship,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}














