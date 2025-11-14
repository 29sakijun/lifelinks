import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/diary_memo_model.dart';
import '../../models/reaction_model.dart';
import '../../providers/data_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../../widgets/image_zoom_dialog.dart';
import 'diary_memo_edit_screen.dart';

class DiaryMemoDetailScreen extends StatefulWidget {
  final DiaryMemoModel diaryMemo;

  const DiaryMemoDetailScreen({super.key, required this.diaryMemo});

  @override
  State<DiaryMemoDetailScreen> createState() => _DiaryMemoDetailScreenState();
}

class _DiaryMemoDetailScreenState extends State<DiaryMemoDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<ReactionModel> _reactions = [];

  @override
  void initState() {
    super.initState();
    if (widget.diaryMemo.isPublic) {
      _loadReactions();
    }
  }

  Future<void> _loadReactions() async {
    _firestoreService.getReactions(widget.diaryMemo.id).listen((reactions) {
      if (mounted) {
        setState(() {
          _reactions = reactions;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          '日記メモ',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.orange),
              onPressed: () {
                final dataProvider =
                    Provider.of<DataProvider>(context, listen: false);
                final latestMemo = dataProvider.diaryMemos.firstWhere(
                  (memo) => memo.id == widget.diaryMemo.id,
                  orElse: () => widget.diaryMemo,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiaryMemoEditScreen(
                      selectedDate: latestMemo.displayDate,
                      memo: latestMemo,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー部分
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.diaryMemo.isPublic
                                  ? Icons.public
                                  : Icons.lock,
                              size: 14,
                              color: widget.diaryMemo.isPublic
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.diaryMemo.isPublic ? '公開' : '非公開',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.diaryMemo.isPublic
                                    ? Colors.green
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        app_date_utils.DateUtils.formatDateTime(
                          widget.diaryMemo.createdAt,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // コンテンツ部分
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.diaryMemo.text.isNotEmpty) ...[
                    Text(
                      widget.diaryMemo.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (widget.diaryMemo.imageUrls.isNotEmpty) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            widget.diaryMemo.imageUrls.length == 1 ? 1 : 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio:
                            widget.diaryMemo.imageUrls.length == 1 ? 16 / 9 : 1,
                      ),
                      itemCount: widget.diaryMemo.imageUrls.length,
                      itemBuilder: (context, index) {
                        final url = widget.diaryMemo.imageUrls[index];
                        return GestureDetector(
                          onTap: () {
                            ImageZoomDialog.show(
                              context,
                              widget.diaryMemo.imageUrls,
                              initialIndex: index,
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  // リアクション表示（公開記事でリアクションがある場合）
                  if (widget.diaryMemo.isPublic && _reactions.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 18,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'みんなのリアクション',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade900,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildReactionSummary(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionSummary() {
    // リアクションをグループ化
    final reactionGroups = <String, int>{};
    for (final reaction in _reactions) {
      reactionGroups[reaction.reaction] =
          (reactionGroups[reaction.reaction] ?? 0) + 1;
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: reactionGroups.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.orange.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.orange.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
