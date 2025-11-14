import 'package:cloud_firestore/cloud_firestore.dart';

enum ShiftType {
  workplace, // 勤務先マスターから
  temporary, // 単発バイト
  other, // その他
}

enum RepeatType {
  none, // しない
  daily, // 毎日
  weekly, // 毎週
}

class ShiftModel {
  final String id;
  final String userId;
  final String? workplaceId; // workplaceの場合のみ
  final ShiftType shiftType;
  final String workplaceName; // 表示用
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final double? hourlyRate; // 単発・その他の場合
  final double? dailyRate; // 単発・その他の場合
  final double allowanceAmount; // 手当
  final String allowanceMemo; // 手当メモ（30文字）
  final double deductionAmount; // 天引
  final String deductionMemo; // 天引メモ（30文字）
  final String memo; // メモ（200文字）
  final bool isPublic; // 公開フラグ
  final DateTime createdAt;

  ShiftModel({
    required this.id,
    required this.userId,
    this.workplaceId,
    required this.shiftType,
    required this.workplaceName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.hourlyRate,
    this.dailyRate,
    this.allowanceAmount = 0.0,
    this.allowanceMemo = '',
    this.deductionAmount = 0.0,
    this.deductionMemo = '',
    this.memo = '',
    this.isPublic = false,
    required this.createdAt,
  });

  factory ShiftModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShiftModel(
      id: doc.id,
      userId: data['userId'],
      workplaceId: data['workplaceId'],
      shiftType: ShiftType.values[data['shiftType'] ?? 0],
      workplaceName: data['workplaceName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      hourlyRate: data['hourlyRate']?.toDouble(),
      dailyRate: data['dailyRate']?.toDouble(),
      allowanceAmount: (data['allowanceAmount'] ?? 0.0).toDouble(),
      allowanceMemo: data['allowanceMemo'] ?? '',
      deductionAmount: (data['deductionAmount'] ?? 0.0).toDouble(),
      deductionMemo: data['deductionMemo'] ?? '',
      memo: data['memo'] ?? '',
      isPublic: data['isPublic'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'workplaceId': workplaceId,
      'shiftType': shiftType.index,
      'workplaceName': workplaceName,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'allowanceAmount': allowanceAmount,
      'allowanceMemo': allowanceMemo,
      'deductionAmount': deductionAmount,
      'deductionMemo': deductionMemo,
      'memo': memo,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // 勤務時間を計算（分単位）
  int get workMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  // 勤務時間を計算（時間単位）
  double get workHours {
    return workMinutes / 60.0;
  }
}

