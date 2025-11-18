import 'package:intl/intl.dart';

class DateUtils {
  // 日付をYYYY-MM-DD形式に変換
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // 日付を表示用の形式に変換（例：2024年1月1日）
  static String formatDateDisplay(DateTime date) {
    return DateFormat('yyyy年M月d日').format(date);
  }

  // 月年を表示用の形式に変換（例：2024年1月）
  static String formatMonthYear(DateTime date) {
    return DateFormat('yyyy年M月').format(date);
  }

  // 時刻を表示用の形式に変換（例：14:30）
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // 日時を表示用の形式に変換（例：2024年1月1日 14:30）
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy年M月d日 HH:mm').format(dateTime);
  }

  // 曜日を取得
  static String getWeekday(DateTime date) {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return weekdays[date.weekday % 7];
  }

  // 月末の日付を取得
  static int getLastDayOfMonth(int year, int month) {
    final nextMonth = month == 12
        ? DateTime(year + 1, 1)
        : DateTime(year, month + 1);
    final lastDay = nextMonth.subtract(const Duration(days: 1));
    return lastDay.day;
  }

  // 締日から給料日までの期間を計算
  // 基準日以降の最も近い給料日を返す
  static DateTime calculatePaymentDate({
    required DateTime baseDate,
    required int closingDay,
    required int paymentMonth,
    required int paymentDay,
  }) {
    // 前月、今月、来月の締日から給料日を計算し、基準日以降の最も近い給料日を見つける
    final candidates = <DateTime>[];
    
    for (int monthOffset = -1; monthOffset <= 2; monthOffset++) {
      int targetMonth = baseDate.month + monthOffset;
      int targetYear = baseDate.year;
      
      while (targetMonth < 1) {
        targetMonth += 12;
        targetYear--;
      }
      while (targetMonth > 12) {
        targetMonth -= 12;
        targetYear++;
      }
      
      // 給料日の月を計算
      int paymentMonthValue = targetMonth + paymentMonth;
      int paymentYear = targetYear;
      while (paymentMonthValue > 12) {
        paymentMonthValue -= 12;
        paymentYear++;
      }
      
      // 給料日（月末対応）
      final lastDay = getLastDayOfMonth(paymentYear, paymentMonthValue);
      final day = paymentDay > lastDay ? lastDay : paymentDay;
      
      final paymentDate = DateTime(paymentYear, paymentMonthValue, day);
      
      // 基準日以降の給料日のみを候補に追加
      if (!paymentDate.isBefore(baseDate)) {
        candidates.add(paymentDate);
      }
    }
    
    // 候補の中から最も近い給料日を返す
    candidates.sort();
    return candidates.first;
  }

  // 2つの日時の差分を時間で返す
  static double getHoursDifference(DateTime start, DateTime end) {
    return end.difference(start).inMinutes / 60.0;
  }
}
