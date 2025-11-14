import '../models/workplace_model.dart';
import '../models/shift_model.dart';

class SalaryCalculator {
  // シフトの給料を計算
  static double calculateShiftSalary({
    required ShiftModel shift,
    WorkplaceModel? workplace,
  }) {
    double totalSalary = 0.0;

    if (shift.shiftType == ShiftType.workplace && workplace != null) {
      // 勤務先マスターから計算
      if (workplace.paymentType == PaymentType.daily) {
        totalSalary = workplace.baseRate;
      } else {
        // 時給の場合
        totalSalary = _calculateHourlySalary(shift, workplace);
      }
    } else {
      // 単発バイト・その他
      if (shift.dailyRate != null) {
        totalSalary = shift.dailyRate!;
      } else if (shift.hourlyRate != null) {
        totalSalary = shift.hourlyRate! * shift.workHours;
      }
    }

    // 手当・天引を加算
    totalSalary += shift.allowanceAmount;
    totalSalary -= shift.deductionAmount;

    return totalSalary;
  }

  // 時給ベースの給料計算（残業・深夜・休日手当含む）
  static double _calculateHourlySalary(
    ShiftModel shift,
    WorkplaceModel workplace,
  ) {
    final baseRate = workplace.baseRate;
    final workMinutes = shift.workMinutes;
    final startTime = shift.startTime;
    final endTime = shift.endTime;

    double totalSalary = 0.0;

    // 基本給
    double normalMinutes = workMinutes.toDouble();
    double overtimeMinutes = 0.0;
    double nightMinutes = 0.0;

    // 深夜時間帯の計算
    nightMinutes = _calculateNightMinutes(
      startTime,
      endTime,
      workplace.nightStartHour,
      workplace.nightEndHour,
    );

    // 休日判定
    final isHoliday = workplace.holidayWeekdays.contains(
      shift.date.weekday % 7,
    );

    // 通常時間の給料
    normalMinutes -= nightMinutes;
    totalSalary += (normalMinutes / 60.0) * baseRate;

    // 深夜手当
    if (nightMinutes > 0) {
      final nightRate = workplace.nightOvertimePayType == OvertimePayType.fixed
          ? workplace.nightOvertimeRate
          : baseRate * (1 + workplace.nightOvertimeRate / 100);
      totalSalary += (nightMinutes / 60.0) * nightRate;
    }

    // 休日手当
    if (isHoliday && workplace.holidayRate > 0) {
      final holidayRate = workplace.holidayPayType == OvertimePayType.fixed
          ? workplace.holidayRate
          : baseRate * (workplace.holidayRate / 100);
      totalSalary += (workMinutes / 60.0) * holidayRate;
    }

    // 交通費
    totalSalary += workplace.transportationFee;

    return totalSalary;
  }

  // 深夜時間帯の分数を計算
  static double _calculateNightMinutes(
    DateTime startTime,
    DateTime endTime,
    int nightStartHour,
    int nightEndHour,
  ) {
    double nightMinutes = 0.0;

    // 深夜時間帯の開始・終了時刻を作成
    final nightStart = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
      nightStartHour,
    );

    DateTime nightEnd;
    if (nightEndHour < nightStartHour) {
      // 深夜時間帯が日をまたぐ場合（例：22時〜翌5時）
      nightEnd = DateTime(
        startTime.year,
        startTime.month,
        startTime.day + 1,
        nightEndHour,
      );
    } else {
      nightEnd = DateTime(
        startTime.year,
        startTime.month,
        startTime.day,
        nightEndHour,
      );
    }

    // 勤務時間と深夜時間帯の重なりを計算
    final overlapStart = startTime.isAfter(nightStart) ? startTime : nightStart;
    final overlapEnd = endTime.isBefore(nightEnd) ? endTime : nightEnd;

    if (overlapStart.isBefore(overlapEnd)) {
      nightMinutes = overlapEnd.difference(overlapStart).inMinutes.toDouble();
    }

    return nightMinutes;
  }

  // 勤務先ごとの総勤務時間と給料見込みを計算
  static Map<String, double> calculateWorkplaceSummary({
    required List<ShiftModel> shifts,
    required List<WorkplaceModel> workplaces,
  }) {
    final workplaceMap = {for (var w in workplaces) w.id: w};

    double totalHours = 0.0;
    double totalSalary = 0.0;

    for (final shift in shifts) {
      totalHours += shift.workHours;

      final workplace = shift.workplaceId != null
          ? workplaceMap[shift.workplaceId]
          : null;

      totalSalary += calculateShiftSalary(shift: shift, workplace: workplace);
    }

    return {'totalHours': totalHours, 'totalSalary': totalSalary};
  }
}















