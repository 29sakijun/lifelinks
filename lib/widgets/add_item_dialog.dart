import 'package:flutter/material.dart';
import '../screens/shift/shift_edit_screen.dart';
import '../screens/diary/diary_memo_edit_screen.dart';
import '../screens/todo/todo_edit_screen.dart';

class AddItemDialog extends StatelessWidget {
  final DateTime selectedDate;

  const AddItemDialog({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '追加する項目を選択',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // シフト
            _buildOptionCard(
              context: context,
              icon: Icons.work,
              iconColor: Colors.blue,
              title: 'シフト',
              subtitle: '勤務時間を記録',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShiftEditScreen(selectedDate: selectedDate),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 日記メモ
            _buildOptionCard(
              context: context,
              icon: Icons.menu_book,
              iconColor: Colors.orange,
              title: '日記メモ',
              subtitle: '今日の出来事を記録',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DiaryMemoEditScreen(selectedDate: selectedDate),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // TODO
            _buildOptionCard(
              context: context,
              icon: Icons.check_box,
              iconColor: Colors.green,
              title: 'TODO',
              subtitle: 'やることを管理',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TodoEditScreen(selectedDate: selectedDate),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // キャンセルボタン
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('キャンセル', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
