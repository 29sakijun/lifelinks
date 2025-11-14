import 'package:cloud_firestore/cloud_firestore.dart';

class ReactionModel {
  final String id;
  final String userId; // リアクションした人
  final String targetId; // 対象の日記メモID
  final String reaction; // リアクション（👍👌😅😲）
  final DateTime createdAt;

  ReactionModel({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.reaction,
    required this.createdAt,
  });

  factory ReactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReactionModel(
      id: doc.id,
      userId: data['userId'],
      targetId: data['targetId'],
      reaction: data['reaction'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'targetId': targetId,
      'reaction': reaction,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ReactionModel copyWith({
    String? id,
    String? userId,
    String? targetId,
    String? reaction,
    DateTime? createdAt,
  }) {
    return ReactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetId: targetId ?? this.targetId,
      reaction: reaction ?? this.reaction,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}















