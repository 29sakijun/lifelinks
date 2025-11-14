import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentType {
  hourly, // 時給
  daily, // 日給
}

enum OvertimePayType {
  fixed, // 固定時給
  percentage, // パーセンテージ
}

class WorkplaceModel {
  final String id;
  final String userId;
  final String name;
  final PaymentType paymentType;
  final double baseRate; // 時給または日給（後方互換性のため保持）
  final double hourlyRate; // 時給
  final double dailyRate; // 日給
  final int closingDay; // 締日（1-30、31=月末）
  final int paymentMonth; // 0=当月、1=翌月、2=翌々月
  final int paymentDay; // 給料日（1-30、31=月末）

  // 給料補足
  final OvertimePayType overtimePayType;
  final double overtimeRate; // 固定時給またはパーセンテージ

  final OvertimePayType nightOvertimePayType;
  final double nightOvertimeRate;
  final int nightStartHour; // 深夜開始時間（0-23）
  final int nightEndHour; // 深夜終了時間（0-23）

  final double transportationFee; // 往復交通費

  final OvertimePayType holidayPayType;
  final double holidayRate;
  final List<int> holidayWeekdays; // 0=日曜、6=土曜

  final DateTime createdAt;

  WorkplaceModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.paymentType,
    this.baseRate = 0.0,
    this.hourlyRate = 0.0,
    this.dailyRate = 0.0,
    required this.closingDay,
    required this.paymentMonth,
    required this.paymentDay,
    this.overtimePayType = OvertimePayType.percentage,
    this.overtimeRate = 25.0,
    this.nightOvertimePayType = OvertimePayType.percentage,
    this.nightOvertimeRate = 25.0,
    this.nightStartHour = 22,
    this.nightEndHour = 5,
    this.transportationFee = 0.0,
    this.holidayPayType = OvertimePayType.percentage,
    this.holidayRate = 0.0,
    this.holidayWeekdays = const [],
    required this.createdAt,
  });

  factory WorkplaceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkplaceModel(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      paymentType: PaymentType.values[data['paymentType'] ?? 0],
      baseRate: (data['baseRate'] ?? 0).toDouble(),
      hourlyRate: (data['hourlyRate'] ?? 0).toDouble(),
      dailyRate: (data['dailyRate'] ?? 0).toDouble(),
      closingDay: data['closingDay'] ?? 31,
      paymentMonth: data['paymentMonth'] ?? 1,
      paymentDay: data['paymentDay'] ?? 25,
      overtimePayType: OvertimePayType.values[data['overtimePayType'] ?? 1],
      overtimeRate: (data['overtimeRate'] ?? 25.0).toDouble(),
      nightOvertimePayType:
          OvertimePayType.values[data['nightOvertimePayType'] ?? 1],
      nightOvertimeRate: (data['nightOvertimeRate'] ?? 25.0).toDouble(),
      nightStartHour: data['nightStartHour'] ?? 22,
      nightEndHour: data['nightEndHour'] ?? 5,
      transportationFee: (data['transportationFee'] ?? 0.0).toDouble(),
      holidayPayType: OvertimePayType.values[data['holidayPayType'] ?? 1],
      holidayRate: (data['holidayRate'] ?? 0.0).toDouble(),
      holidayWeekdays: List<int>.from(data['holidayWeekdays'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'paymentType': paymentType.index,
      'baseRate': baseRate,
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'closingDay': closingDay,
      'paymentMonth': paymentMonth,
      'paymentDay': paymentDay,
      'overtimePayType': overtimePayType.index,
      'overtimeRate': overtimeRate,
      'nightOvertimePayType': nightOvertimePayType.index,
      'nightOvertimeRate': nightOvertimeRate,
      'nightStartHour': nightStartHour,
      'nightEndHour': nightEndHour,
      'transportationFee': transportationFee,
      'holidayPayType': holidayPayType.index,
      'holidayRate': holidayRate,
      'holidayWeekdays': holidayWeekdays,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

