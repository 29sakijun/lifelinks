import 'package:flutter/material.dart';
import '../../utils/date_utils.dart' as app_date_utils;

class TimeSelectModal extends StatefulWidget {
  final DateTime? initialTime;
  final DateTime baseDate;
  final String title;
  final bool allowNextDay; // 翌日選択を許可するかどうか

  const TimeSelectModal({
    super.key,
    this.initialTime,
    required this.baseDate,
    required this.title,
    this.allowNextDay = false,
  });

  @override
  State<TimeSelectModal> createState() => _TimeSelectModalState();
}

class _TimeSelectModalState extends State<TimeSelectModal> {
  late TimeOfDay _selectedTime;
  late String _selectedDayType; // 'today' or 'tomorrow'
  late DateTime _baseDate;
  late ScrollController _hourController;
  late ScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _baseDate = widget.baseDate;

    if (widget.initialTime != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.initialTime!);
      // 初期時間が翌日かどうかを判定
      final initialDate = DateTime(
        widget.initialTime!.year,
        widget.initialTime!.month,
        widget.initialTime!.day,
      );
      final baseDateOnly = DateTime(
        _baseDate.year,
        _baseDate.month,
        _baseDate.day,
      );
      _selectedDayType = initialDate.isAfter(baseDateOnly)
          ? 'tomorrow'
          : 'today';
    } else {
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
      _selectedDayType = 'today';
    }

    // ScrollControllerを初期化
    _hourController = ScrollController(
      initialScrollOffset: _selectedTime.hour * 56.0,
    );
    _minuteController = ScrollController(
      initialScrollOffset: _selectedTime.minute * 56.0,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 日付選択（当日/翌日）- 終了時間のみ表示
            if (widget.allowNextDay) ...[
              Text(
                '日付',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'today', label: const Text('当日')),
                  ButtonSegment(value: 'tomorrow', label: const Text('翌日')),
                ],
                selected: {_selectedDayType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedDayType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // 時間選択
            Text(
              '時間',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 200,
                child: Row(
                  children: [
                    // 時間選択
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '時',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Divider(
                            height: 8,
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: _hourController,
                              clipBehavior: Clip.hardEdge,
                              itemCount: 24,
                              itemBuilder: (context, index) {
                                final hour = index;
                                final isSelected = _selectedTime.hour == hour;
                                return Container(
                                  color: isSelected
                                      ? Colors.grey[100]
                                      : Colors.transparent,
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      hour.toString().padLeft(2, '0'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : null,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedTime = TimeOfDay(
                                          hour: hour,
                                          minute: _selectedTime.minute,
                                        );
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 分選択
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '分',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Divider(
                            height: 8,
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: _minuteController,
                              clipBehavior: Clip.hardEdge,
                              itemCount: 60, // 0-59分
                              itemBuilder: (context, index) {
                                final minute = index;
                                final isSelected =
                                    _selectedTime.minute == minute;
                                return Container(
                                  color: isSelected
                                      ? Colors.grey[100]
                                      : Colors.transparent,
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      minute.toString().padLeft(2, '0'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : null,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedTime = TimeOfDay(
                                          hour: _selectedTime.hour,
                                          minute: minute,
                                        );
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 選択された時間の表示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '選択された時間',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.allowNextDay
                        ? ((_selectedDayType == 'today' ? '当日' : '翌日') +
                              ' ' +
                              app_date_utils.DateUtils.formatTime(
                                DateTime(
                                  _baseDate.year,
                                  _baseDate.month,
                                  _baseDate.day,
                                  _selectedTime.hour,
                                  _selectedTime.minute,
                                ),
                              ))
                        : app_date_utils.DateUtils.formatTime(
                            DateTime(
                              _baseDate.year,
                              _baseDate.month,
                              _baseDate.day,
                              _selectedTime.hour,
                              _selectedTime.minute,
                            ),
                          ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ボタン
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 選択された日付と時間を組み合わせてDateTimeを作成
                      final selectedDate =
                          widget.allowNextDay && _selectedDayType == 'tomorrow'
                          ? _baseDate.add(const Duration(days: 1))
                          : _baseDate;

                      final resultDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );

                      Navigator.of(context).pop(resultDateTime);
                    },
                    child: const Text('決定'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<DateTime?> showTimeSelectModal(
  BuildContext context, {
  DateTime? initialTime,
  required DateTime baseDate,
  required String title,
  bool allowNextDay = false,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => TimeSelectModal(
      initialTime: initialTime,
      baseDate: baseDate,
      title: title,
      allowNextDay: allowNextDay,
    ),
  );
}
