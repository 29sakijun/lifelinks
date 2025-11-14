import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/friendship_model.dart';
import 'friend_edit_screen.dart';
import 'qr_scan_screen.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final sortedFriendships = dataProvider.friendships.toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Scaffold(
      appBar: AppBar(
        title: const Text('友達リスト'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScanScreen()),
              );
            },
          ),
        ],
      ),
      body: sortedFriendships.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '友達がいません',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QRScanScreen()),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('友達を追加'),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: sortedFriendships.length,
              onReorder: (oldIndex, newIndex) {
                _reorderFriends(
                  dataProvider,
                  sortedFriendships,
                  oldIndex,
                  newIndex,
                );
              },
              itemBuilder: (context, index) {
                final friendship = sortedFriendships[index];
                return Card(
                  key: ValueKey(friendship.id),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle, color: Colors.grey),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundImage:
                              friendship.friendProfileImageUrl != null
                              ? NetworkImage(friendship.friendProfileImageUrl!)
                              : null,
                          backgroundColor: friendship.friendColor,
                          child: friendship.friendProfileImageUrl == null
                              ? Text(
                                  friendship.friendNickname[0],
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                      ],
                    ),
                    title: Text(friendship.friendNickname),
                    subtitle: Text(
                      [
                        if (friendship.shareDiaryMemo) '日記',
                        if (friendship.shareTodo) 'TODO',
                        if (friendship.shareShift) 'シフト',
                      ].join('・'),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FriendEditScreen(friendship: friendship),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Future<void> _reorderFriends(
    DataProvider dataProvider,
    List<FriendshipModel> friendships,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // 並び替え
    final item = friendships.removeAt(oldIndex);
    friendships.insert(newIndex, item);

    // displayOrderを更新
    for (int i = 0; i < friendships.length; i++) {
      final updated = friendships[i].copyWith(displayOrder: i);
      await dataProvider.updateFriendship(updated);
    }
  }
}
