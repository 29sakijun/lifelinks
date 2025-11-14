import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryMemoModel {
  final String id;
  final String userId;
  final String? targetDate; // 対象日（YYYY-MM-DD形式）nullの場合は作成日のみ
  final String text; // テキスト（500文字まで）
  final List<String> imageUrls; // 画像URL
  final bool isPublic; // 公開フラグ
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryMemoModel({
    required this.id,
    required this.userId,
    this.targetDate,
    required this.text,
    this.imageUrls = const [],
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiaryMemoModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DiaryMemoModel(
      id: doc.id,
      userId: data['userId'],
      targetDate: data['targetDate'],
      text: data['text'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      isPublic: data['isPublic'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'targetDate': targetDate,
      'text': text,
      'imageUrls': imageUrls,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // カレンダーに表示する日付
  DateTime get displayDate {
    if (targetDate != null) {
      return DateTime.parse(targetDate!);
    }
    return createdAt;
  }
}
