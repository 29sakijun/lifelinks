import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/shift_model.dart';
import '../../models/workplace_model.dart';
import '../../constants/app_constants.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../../widgets/time_select_modal.dart';
import 'workplace_select_screen.dart';

class ShiftEditScreen extends StatefulWidget {
  final DateTime selectedDate;
  final ShiftModel? shift;

  const ShiftEditScreen({super.key, required this.selectedDate, this.shift});

  @override
  State<ShiftEditScreen> createState() => _ShiftEditScreenState();
}

class _ShiftEditScreenState extends State<ShiftEditScreen> {
  WorkplaceModel? _selectedWorkplace;
  ShiftType _shiftType = ShiftType.workplace;
  String _workplaceName = '';
  DateTime? _startTime;
  DateTime? _endTime;
  double? _hourlyRate;
  double? _dailyRate;
  double _allowanceAmount = 0.0;
  String _allowanceMemo = '';
  double _deductionAmount = 0.0;
  String _deductionMemo = '';
  String _memo = '';
  bool _isPublic = false;
  RepeatType _repeatType = RepeatType.none;
  int _repeatInterval = 1;
  DateTime? _repeatEndDate;
  Set<int> _repeatWeekdays = {}; // 1=月曜日, 2=火曜日, ..., 7=日曜日

  final TextEditingController _workplaceNameController =
      TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _dailyRateController = TextEditingController();
  final TextEditingController _allowanceController = TextEditingController();
  final TextEditingController _allowanceMemoController =
      TextEditingController();
  final TextEditingController _deductionController = TextEditingController();
  final TextEditingController _deductionMemoController =
      TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.shift != null) {
      final shift = widget.shift!;
      _shiftType = shift.shiftType;
      _workplaceName = shift.workplaceName;
      _startTime = shift.startTime;
      _endTime = shift.endTime;
      _hourlyRate = shift.hourlyRate;
      _dailyRate = shift.dailyRate;
      _allowanceAmount = shift.allowanceAmount;
      _allowanceMemo = shift.allowanceMemo;
      _deductionAmount = shift.deductionAmount;
      _deductionMemo = shift.deductionMemo;
      _memo = shift.memo;
      _isPublic = shift.isPublic;

      // 勤務先マスターの場合、workplaceIdから勤務先を取得
      if (shift.shiftType == ShiftType.workplace && shift.workplaceId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final dataProvider = Provider.of<DataProvider>(
            context,
            listen: false,
          );
          final workplace = dataProvider.workplaces.firstWhere(
            (w) => w.id == shift.workplaceId,
            orElse: () => WorkplaceModel(
              id: '',
              userId: '',
              name: shift.workplaceName,
              paymentType: PaymentType.hourly,
              baseRate: 0,
              closingDay: 1,
              paymentMonth: 1,
              paymentDay: 1,
              createdAt: DateTime.now(),
            ),
          );
          if (workplace.id.isNotEmpty) {
            setState(() {
              _selectedWorkplace = workplace;
            });
          }
        });
      }

      _workplaceNameController.text = _workplaceName;
      _hourlyRateController.text = _hourlyRate?.toInt().toString() ?? '';
      _dailyRateController.text = _dailyRate?.toInt().toString() ?? '';
      _allowanceController.text = _allowanceAmount.toInt().toString();
      _allowanceMemoController.text = _allowanceMemo;
      _deductionController.text = _deductionAmount.toInt().toString();
      _deductionMemoController.text = _deductionMemo;
      _memoController.text = _memo;
    }
  }

  @override
  void dispose() {
    _workplaceNameController.dispose();
    _hourlyRateController.dispose();
    _dailyRateController.dispose();
    _allowanceController.dispose();
    _allowanceMemoController.dispose();
    _deductionController.dispose();
    _deductionMemoController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final result = await showTimeSelectModal(
      context,
      initialTime: isStartTime ? _startTime : _endTime,
      baseDate: widget.selectedDate,
      title: isStartTime ? '開始時間を選択' : '終了時間を選択',
      allowNextDay: !isStartTime, // 終了時間のみ翌日選択を許可
    );

    if (result != null) {
      setState(() {
        if (isStartTime) {
          _startTime = result;
        } else {
          _endTime = result;
        }
      });
    }
  }

  Future<void> _selectWorkplace() async {
    final workplace = await Navigator.push<WorkplaceModel>(
      context,
      MaterialPageRoute(builder: (_) => const WorkplaceSelectScreen()),
    );

    if (workplace != null) {
      setState(() {
        _selectedWorkplace = workplace;
        _shiftType = ShiftType.workplace;
        _workplaceName = workplace.name;
      });
    }
  }

  Future<void> _saveShift() async {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('開始時間と終了時間を設定してください')));
      return;
    }

    if (_workplaceName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('勤務先を設定してください')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final shift = ShiftModel(
      id: widget.shift?.id ?? '',
      userId: authProvider.user!.uid,
      workplaceId: _selectedWorkplace?.id,
      shiftType: _shiftType,
      workplaceName: _workplaceName,
      date: widget.selectedDate,
      startTime: _startTime!,
      endTime: _endTime!,
      hourlyRate: _hourlyRate,
      dailyRate: _dailyRate,
      allowanceAmount: _allowanceAmount,
      allowanceMemo: _allowanceMemo,
      deductionAmount: _deductionAmount,
      deductionMemo: _deductionMemo,
      memo: _memo,
      isPublic: _isPublic,
      createdAt: widget.shift?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.shift != null) {
        await dataProvider.updateShift(shift);
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        // 繰り返し保存
        await _saveRepeatShifts(dataProvider, shift);
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }

  Future<void> _saveRepeatShifts(
    DataProvider dataProvider,
    ShiftModel shift,
  ) async {
    // 繰り返しがない場合は1件だけ保存
    if (_repeatType == RepeatType.none) {
      await dataProvider.addShift(shift);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('シフトを登録しました')));
      }
      return;
    }

    DateTime startDate = shift.date;
    int savedCount = 0;

    // 終了日が設定されていない場合は1年後に設定
    final endDate = _repeatEndDate ?? startDate.add(const Duration(days: 365));

    if (_repeatType == RepeatType.weekly) {
      List<int> sortedWeekdays = _repeatWeekdays.toList()..sort();

      // 最初の週の各曜日の日付を計算
      Map<int, DateTime> weekdayToDate = {};
      int startWeekday = startDate.weekday;

      for (int weekday in sortedWeekdays) {
        int daysOffset;
        if (weekday >= startWeekday) {
          // 同じ週内
          daysOffset = weekday - startWeekday;
        } else {
          // 次の週（日曜日(7)の後に月曜日(1)などが来る場合）
          daysOffset = (7 - startWeekday) + weekday;
        }
        DateTime targetDate = startDate.add(Duration(days: daysOffset));
        weekdayToDate[weekday] = targetDate;
      }

      // 日付順にソート
      List<DateTime> firstWeekDates = weekdayToDate.values.toList()..sort();

      // 各曜日について、間隔ごとに日付を生成
      for (DateTime firstDate in firstWeekDates) {
        DateTime currentDate = firstDate;

        while (currentDate.isBefore(endDate) ||
            currentDate.isAtSameMomentAs(endDate)) {
          // 日付を更新
          final startTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            shift.startTime.hour,
            shift.startTime.minute,
          );

          // 終了時間が開始時間より前の場合は翌日
          final endDayOffset = shift.endTime.isBefore(shift.startTime) ? 1 : 0;
          final endTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day + endDayOffset,
            shift.endTime.hour,
            shift.endTime.minute,
          );

          final repeatedShift = ShiftModel(
            id: '',
            userId: shift.userId,
            workplaceId: shift.workplaceId,
            shiftType: shift.shiftType,
            workplaceName: shift.workplaceName,
            date: currentDate,
            startTime: startTime,
            endTime: endTime,
            hourlyRate: shift.hourlyRate,
            dailyRate: shift.dailyRate,
            allowanceAmount: shift.allowanceAmount,
            allowanceMemo: shift.allowanceMemo,
            deductionAmount: shift.deductionAmount,
            deductionMemo: shift.deductionMemo,
            memo: shift.memo,
            isPublic: shift.isPublic,
            createdAt: DateTime.now(),
          );

          await dataProvider.addShift(repeatedShift);
          savedCount++;

          // 次の繰り返しの日付を計算
          int daysToAdd = 7 * _repeatInterval;
          currentDate = currentDate.add(Duration(days: daysToAdd));
        }
      }
    } else {
      // 毎日の場合
      DateTime currentDate = startDate;
      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        final startTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          shift.startTime.hour,
          shift.startTime.minute,
        );

        final endDayOffset = shift.endTime.isBefore(shift.startTime) ? 1 : 0;
        final endTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day + endDayOffset,
          shift.endTime.hour,
          shift.endTime.minute,
        );

        final repeatedShift = ShiftModel(
          id: '',
          userId: shift.userId,
          workplaceId: shift.workplaceId,
          shiftType: shift.shiftType,
          workplaceName: shift.workplaceName,
          date: currentDate,
          startTime: startTime,
          endTime: endTime,
          hourlyRate: shift.hourlyRate,
          dailyRate: shift.dailyRate,
          allowanceAmount: shift.allowanceAmount,
          allowanceMemo: shift.allowanceMemo,
          deductionAmount: shift.deductionAmount,
          deductionMemo: shift.deductionMemo,
          memo: shift.memo,
          isPublic: shift.isPublic,
          createdAt: DateTime.now(),
        );

        await dataProvider.addShift(repeatedShift);
        savedCount++;

        currentDate = currentDate.add(Duration(days: _repeatInterval));
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$savedCount件のシフトを登録しました')));
    }
  }

  Widget _buildWeekdayChip(int weekday, String label) {
    final isSelected = _repeatWeekdays.contains(weekday);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _repeatWeekdays.add(weekday);
          } else {
            _repeatWeekdays.remove(weekday);
          }
        });
      },
    );
  }

  Future<void> _deleteShift() async {
    if (widget.shift == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('このシフトを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      await dataProvider.deleteShift(widget.shift!.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
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
          widget.shift != null ? 'シフト編集' : 'シフト追加',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: widget.shift != null
            ? [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteShift,
                  ),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 勤務先セクション
            Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.business,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '勤務先',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ShiftType>(
                      segments: const [
                        ButtonSegment(
                          value: ShiftType.workplace,
                          label: Text('勤務先'),
                        ),
                        ButtonSegment(
                          value: ShiftType.temporary,
                          label: Text('単発'),
                        ),
                        ButtonSegment(
                          value: ShiftType.other,
                          label: Text('その他'),
                        ),
                      ],
                      selected: {_shiftType},
                      onSelectionChanged: (Set<ShiftType> newSelection) {
                        setState(() {
                          _shiftType = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>((
                              Set<MaterialState> states,
                            ) {
                              if (states.contains(MaterialState.selected)) {
                                return const Color(0xFF0083DF);
                              }
                              return null;
                            }),
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color?>((
                              Set<MaterialState> states,
                            ) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.white;
                              }
                              return null;
                            }),
                        side: MaterialStateProperty.resolveWith<BorderSide?>((
                          Set<MaterialState> states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return const BorderSide(color: Color(0xFF0083DF));
                          }
                          return const BorderSide(
                            color: Color(0xFF0083DF),
                            width: 0.3,
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_shiftType == ShiftType.workplace)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _selectWorkplace,
                        icon: const Icon(Icons.business),
                        label: Text(_selectedWorkplace?.name ?? '勤務先を選択'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    )
                  else
                    TextField(
                      controller: _workplaceNameController,
                      decoration: InputDecoration(
                        labelText: '勤務先名',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFF0083DF),
                          ),
                        ),
                      ),
                      onChanged: (value) => _workplaceName = value,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 勤務時間セクション
            Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '勤務時間',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _startTime != null
                                  ? const Color(0xFF0083DF)
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: OutlinedButton(
                            onPressed: () => _selectTime(context, true),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              _startTime != null
                                  ? app_date_utils.DateUtils.formatTime(
                                      _startTime!,
                                    )
                                  : '開始時間',
                              style: TextStyle(
                                color: _startTime != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '〜',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _endTime != null
                                  ? const Color(0xFF0083DF)
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: OutlinedButton(
                            onPressed: () => _selectTime(context, false),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              _endTime != null
                                  ? app_date_utils.DateUtils.formatTime(
                                      _endTime!,
                                    )
                                  : '終了時間',
                              style: TextStyle(
                                color: _endTime != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 給料セクション（勤務先以外の場合のみ）
            if (_shiftType != ShiftType.workplace) ...[
              const SizedBox(height: 16),
              Container(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.monetization_on,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '給料',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _hourlyRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '時給',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        suffixText: '円',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFF0083DF),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _hourlyRate = int.tryParse(value)?.toDouble();
                          // 時給が入力されたら日給をクリア
                          if (_hourlyRate != null && _hourlyRate! > 0) {
                            _dailyRateController.clear();
                            _dailyRate = null;
                          }
                        } else {
                          _hourlyRate = null;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dailyRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '日給',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        suffixText: '円',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFF0083DF),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _dailyRate = int.tryParse(value)?.toDouble();
                          // 日給が入力されたら時給をクリア
                          if (_dailyRate != null && _dailyRate! > 0) {
                            _hourlyRateController.clear();
                            _hourlyRate = null;
                          }
                        } else {
                          _dailyRate = null;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 繰り返し設定（折りたたみ）- 新規追加時のみ
            if (widget.shift == null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: ExpansionTile(
                  initiallyExpanded: false,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                  childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.repeat,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '繰り返し',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    const SizedBox(height: 8),
                    SegmentedButton<RepeatType>(
                      segments: const [
                        ButtonSegment(
                          value: RepeatType.none,
                          label: Text('しない'),
                        ),
                        ButtonSegment(
                          value: RepeatType.daily,
                          label: Text('毎日'),
                        ),
                        ButtonSegment(
                          value: RepeatType.weekly,
                          label: Text('毎週'),
                        ),
                      ],
                      selected: {_repeatType},
                      showSelectedIcon: false,
                      onSelectionChanged: (Set<RepeatType> newSelection) {
                        setState(() {
                          _repeatType = newSelection.first;
                          if (_repeatType == RepeatType.weekly &&
                              _repeatWeekdays.isEmpty) {
                            _repeatWeekdays = {widget.selectedDate.weekday};
                          }
                        });
                      },
                    ),
                    if (_repeatType != RepeatType.none) ...[
                      if (_repeatType == RepeatType.weekly) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '曜日を選択',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildWeekdayChip(7, '日'),
                          _buildWeekdayChip(1, '月'),
                          _buildWeekdayChip(2, '火'),
                          _buildWeekdayChip(3, '水'),
                          _buildWeekdayChip(4, '木'),
                          _buildWeekdayChip(5, '金'),
                          _buildWeekdayChip(6, '土'),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '間隔',
                        helperText: _repeatType == RepeatType.daily
                            ? '2 で2日ごと'
                            : '2 で2週間ごと',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onChanged: (value) {
                        _repeatInterval = int.tryParse(value) ?? 1;
                      },
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('終了しない')),
                        ButtonSegment(value: true, label: Text('終了日を設定')),
                      ],
                      selected: {_repeatEndDate != null},
                      showSelectedIcon: false,
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() {
                          if (newSelection.first) {
                            _repeatEndDate = DateTime.now().add(
                              const Duration(days: 30),
                            );
                          } else {
                            _repeatEndDate = null;
                          }
                        });
                      },
                    ),
                    if (_repeatEndDate != null) ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _repeatEndDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            locale: const Locale('ja', 'JP'),
                          );
                          if (picked != null) {
                            setState(() {
                              _repeatEndDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: '終了日',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            DateFormat('yyyy年M月d日').format(_repeatEndDate!),
                          ),
                        ),
                      ),
                    ],
                    ],
                  ],
                ),
              ),

            // 手当・天引セクション（折りたたみ）
            Container(
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
              child: ExpansionTile(
                initiallyExpanded: false,
                tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.purple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '手当・天引',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                children: [
                  const SizedBox(height: 8),
                  TextField(
                    controller: _allowanceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '手当',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      suffixText: '円',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF0083DF)),
                      ),
                    ),
                    onChanged: (value) {
                      _allowanceAmount = int.tryParse(value)?.toDouble() ?? 0.0;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _allowanceMemoController,
                    maxLength: AppConstants.maxMemoLength,
                    decoration: InputDecoration(
                      labelText: '手当メモ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF0083DF)),
                      ),
                    ),
                    onChanged: (value) {
                      _allowanceMemo = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _deductionController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '天引',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      suffixText: '円',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF0083DF)),
                      ),
                    ),
                    onChanged: (value) {
                      _deductionAmount = int.tryParse(value)?.toDouble() ?? 0.0;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _deductionMemoController,
                    maxLength: AppConstants.maxMemoLength,
                    decoration: InputDecoration(
                      labelText: '天引メモ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF0083DF)),
                      ),
                    ),
                    onChanged: (value) {
                      _deductionMemo = value;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // メモ・公開セクション
            Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.note,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'メモ・公開',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _memoController,
                    maxLength: AppConstants.maxShiftMemoLength,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'メモ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF0083DF)),
                      ),
                    ),
                    onChanged: (value) {
                      _memo = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SwitchListTile(
                      title: const Text('公開する'),
                      subtitle: const Text('友達にシフトを公開します'),
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 保存ボタン
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveShift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  '保存',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
