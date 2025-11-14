import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? nickname;
  final String? profileImageUrl; // プロフィール画像のURL
  final String qrCode; // ユーザー固有のQRコード用ID
  final DateTime createdAt;
  final bool acceptedTerms;
  final bool acceptedPrivacyPolicy;

  UserModel({
    required this.uid,
    this.nickname,
    this.profileImageUrl,
    required this.qrCode,
    required this.createdAt,
    required this.acceptedTerms,
    required this.acceptedPrivacyPolicy,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nickname: data['nickname'],
      profileImageUrl: data['profileImageUrl'],
      qrCode: data['qrCode'] ?? doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      acceptedTerms: data['acceptedTerms'] ?? false,
      acceptedPrivacyPolicy: data['acceptedPrivacyPolicy'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'qrCode': qrCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedTerms': acceptedTerms,
      'acceptedPrivacyPolicy': acceptedPrivacyPolicy,
    };
  }

  String get displayName => nickname ?? '秘密';
}
