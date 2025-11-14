import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendshipModel {
  final String id;
  final String userId; // 自分のID
  final String friendId; // 友達のID
  final String friendNickname; // 友達のニックネーム
  final String? friendProfileImageUrl; // 友達のプロフィール画像URL
  final Color friendColor; // 友達に設定した色
  final bool shareDiaryMemo; // 日記メモを公開
  final bool shareTodo; // TODOを公開
  final bool shareShift; // シフトを公開
  final int displayOrder; // 表示順（小さい方が上）
  final DateTime? lastViewedAt; // 最後に閲覧した日時
  final DateTime createdAt;

  FriendshipModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendNickname,
    this.friendProfileImageUrl,
    this.friendColor = Colors.blue,
    this.shareDiaryMemo = false,
    this.shareTodo = false,
    this.shareShift = false,
    this.displayOrder = 0,
    this.lastViewedAt,
    required this.createdAt,
  });

  factory FriendshipModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FriendshipModel(
      id: doc.id,
      userId: data['userId'],
      friendId: data['friendId'],
      friendNickname: data['friendNickname'] ?? '秘密',
      friendProfileImageUrl: data['friendProfileImageUrl'],
      friendColor: Color(data['friendColor'] ?? Colors.blue.value),
      shareDiaryMemo: data['shareDiaryMemo'] ?? false,
      shareTodo: data['shareTodo'] ?? false,
      shareShift: data['shareShift'] ?? false,
      displayOrder: data['displayOrder'] ?? 0,
      lastViewedAt: data['lastViewedAt'] != null
          ? (data['lastViewedAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
      'friendNickname': friendNickname,
      'friendProfileImageUrl': friendProfileImageUrl,
      'friendColor': friendColor.value,
      'shareDiaryMemo': shareDiaryMemo,
      'shareTodo': shareTodo,
      'shareShift': shareShift,
      'displayOrder': displayOrder,
      'lastViewedAt': lastViewedAt != null
          ? Timestamp.fromDate(lastViewedAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FriendshipModel copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? friendNickname,
    String? friendProfileImageUrl,
    Color? friendColor,
    bool? shareDiaryMemo,
    bool? shareTodo,
    bool? shareShift,
    int? displayOrder,
    DateTime? lastViewedAt,
    DateTime? createdAt,
  }) {
    return FriendshipModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      friendNickname: friendNickname ?? this.friendNickname,
      friendProfileImageUrl:
          friendProfileImageUrl ?? this.friendProfileImageUrl,
      friendColor: friendColor ?? this.friendColor,
      shareDiaryMemo: shareDiaryMemo ?? this.shareDiaryMemo,
      shareTodo: shareTodo ?? this.shareTodo,
      shareShift: shareShift ?? this.shareShift,
      displayOrder: displayOrder ?? this.displayOrder,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
