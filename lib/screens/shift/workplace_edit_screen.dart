import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/workplace_model.dart';

class WorkplaceEditScreen extends StatefulWidget {
  final WorkplaceModel? workplace;

  const WorkplaceEditScreen({super.key, this.workplace});

  @override
  State<WorkplaceEditScreen> createState() => _WorkplaceEditScreenState();
}

class _WorkplaceEditScreenState extends State<WorkplaceEditScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  PaymentType _paymentType = PaymentType.hourly;
  double _baseRate = 0;
  int _hourlyRate = 0;
  int _dailyRate = 0;
  int _closingDay = 31;
  int _paymentMonth = 1;
  int _paymentDay = 25;

  bool _showAdvanced = false;
  OvertimePayType _overtimePayType = OvertimePayType.percentage;
  double _overtimeRate = 25.0;
  OvertimePayType _nightOvertimePayType = OvertimePayType.percentage;
  double _nightOvertimeRate = 25.0;
  int _nightStartHour = 22;
  int _nightEndHour = 5;
  double _transportationFee = 0.0;
  OvertimePayType _holidayPayType = OvertimePayType.percentage;
  double _holidayRate = 0.0;
  List<int> _holidayWeekdays = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _baseRateController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _dailyRateController = TextEditingController();
  final TextEditingController _overtimeRateController = TextEditingController();
  final TextEditingController _nightOvertimeRateController =
      TextEditingController();
  final TextEditingController _transportationFeeController =
      TextEditingController();
  final TextEditingController _holidayRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.workplace != null) {
      _initializeFromWorkplace(widget.workplace!);
    } else {
      _overtimeRateController.text = '25.0';
      _nightOvertimeRateController.text = '25.0';
      _transportationFeeController.text = '0';
      _holidayRateController.text = '0';
    }
  }

  void _initializeFromWorkplace(WorkplaceModel workplace) {
    _name = workplace.name;
    _paymentType = workplace.paymentType;
    _baseRate = workplace.baseRate;
    _hourlyRate = workplace.hourlyRate.toInt();
    _dailyRate = workplace.dailyRate.toInt();
    _closingDay = workplace.closingDay;
    _paymentMonth = workplace.paymentMonth;
    _paymentDay = workplace.paymentDay;
    _overtimePayType = workplace.overtimePayType;
    _overtimeRate = workplace.overtimeRate;
    _nightOvertimePayType = workplace.nightOvertimePayType;
    _nightOvertimeRate = workplace.nightOvertimeRate;
    _nightStartHour = workplace.nightStartHour;
    _nightEndHour = workplace.nightEndHour;
    _transportationFee = workplace.transportationFee;
    _holidayPayType = workplace.holidayPayType;
    _holidayRate = workplace.holidayRate;
    _holidayWeekdays = List.from(workplace.holidayWeekdays);

    _nameController.text = _name;
    _baseRateController.text = _baseRate.toString();
    _hourlyRateController.text = _hourlyRate.toString();
    _dailyRateController.text = _dailyRate.toString();
    _overtimeRateController.text = _overtimeRate.toString();
    _nightOvertimeRateController.text = _nightOvertimeRate.toString();
    _transportationFeeController.text = _transportationFee.toString();
    _holidayRateController.text = _holidayRate.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseRateController.dispose();
    _hourlyRateController.dispose();
    _dailyRateController.dispose();
    _overtimeRateController.dispose();
    _nightOvertimeRateController.dispose();
    _transportationFeeController.dispose();
    _holidayRateController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkplace() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final workplace = WorkplaceModel(
      id: widget.workplace?.id ?? '',
      userId: authProvider.user!.uid,
      name: _name,
      paymentType: _paymentType,
      baseRate: _paymentType == PaymentType.hourly
          ? _hourlyRate.toDouble()
          : _dailyRate.toDouble(),
      hourlyRate: _hourlyRate.toDouble(),
      dailyRate: _dailyRate.toDouble(),
      closingDay: _closingDay,
      paymentMonth: _paymentMonth,
      paymentDay: _paymentDay,
      overtimePayType: _overtimePayType,
      overtimeRate: _overtimeRate,
      nightOvertimePayType: _nightOvertimePayType,
      nightOvertimeRate: _nightOvertimeRate,
      nightStartHour: _nightStartHour,
      nightEndHour: _nightEndHour,
      transportationFee: _transportationFee,
      holidayPayType: _holidayPayType,
      holidayRate: _holidayRate,
      holidayWeekdays: _holidayWeekdays,
      createdAt: widget.workplace?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.workplace != null) {
        await dataProvider.updateWorkplace(workplace);
      } else {
        await dataProvider.addWorkplace(workplace);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }

  Future<void> _deleteWorkplace() async {
    if (widget.workplace == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この勤務先を削除しますか？\n関連するシフトは削除されません。'),
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
      await dataProvider.deleteWorkplace(widget.workplace!.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workplace != null ? '勤務先編集' : '勤務先追加'),
        actions: widget.workplace != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteWorkplace,
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '勤務先名',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '勤務先名を入力してください';
                        }
                        return null;
                      },
                      onChanged: (value) => _name = value,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '給料タイプ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<PaymentType>(
                      segments: const [
                        ButtonSegment(
                          value: PaymentType.hourly,
                          label: Text('時給'),
                        ),
                        ButtonSegment(
                          value: PaymentType.daily,
                          label: Text('日給'),
                        ),
                      ],
                      selected: {_paymentType},
                      onSelectionChanged: (Set<PaymentType> newSelection) {
                        setState(() {
                          _paymentType = newSelection.first;
                        });
                        // タブ変更時にフォーム検証を再実行
                        _formKey.currentState?.validate();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hourlyRateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '時給',
                        border: OutlineInputBorder(),
                        suffixText: '円',
                      ),
                      validator: (value) {
                        // 時給タブが選択されている場合のみ必須
                        if (_paymentType == PaymentType.hourly) {
                          if (value == null || value.isEmpty) {
                            return '金額を入力してください';
                          }
                          if (int.tryParse(value) == null) {
                            return '数値を入力してください';
                          }
                        }
                        return null;
                      },
                      onChanged: (value) =>
                          _hourlyRate = int.tryParse(value) ?? 0,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dailyRateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '日給',
                        border: OutlineInputBorder(),
                        suffixText: '円',
                      ),
                      validator: (value) {
                        // 日給タブが選択されている場合のみ必須
                        if (_paymentType == PaymentType.daily) {
                          if (value == null || value.isEmpty) {
                            return '金額を入力してください';
                          }
                          if (int.tryParse(value) == null) {
                            return '数値を入力してください';
                          }
                        }
                        return null;
                      },
                      onChanged: (value) =>
                          _dailyRate = int.tryParse(value) ?? 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('締日・給料日', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _closingDay,
                decoration: const InputDecoration(
                  labelText: '締日',
                  border: OutlineInputBorder(),
                ),
                items: [
                  ...List.generate(30, (index) => index + 1).map((day) {
                    return DropdownMenuItem(value: day, child: Text('$day日'));
                  }),
                  const DropdownMenuItem(value: 31, child: Text('月末')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _closingDay = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _paymentMonth,
                      decoration: const InputDecoration(
                        labelText: '給料月',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('当月')),
                        DropdownMenuItem(value: 1, child: Text('翌月')),
                        DropdownMenuItem(value: 2, child: Text('翌々月')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _paymentMonth = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _paymentDay,
                      decoration: const InputDecoration(
                        labelText: '給料日',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        ...List.generate(30, (index) => index + 1).map((day) {
                          return DropdownMenuItem(
                            value: day,
                            child: Text('$day日'),
                          );
                        }),
                        const DropdownMenuItem(value: 31, child: Text('月末')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _paymentDay = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ExpansionTile(
                title: const Text('給料補足'),
                initiallyExpanded: _showAdvanced,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _showAdvanced = expanded;
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '残業',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<OvertimePayType>(
                          segments: const [
                            ButtonSegment(
                              value: OvertimePayType.fixed,
                              label: Text('時給'),
                            ),
                            ButtonSegment(
                              value: OvertimePayType.percentage,
                              label: Text('%'),
                            ),
                          ],
                          selected: {_overtimePayType},
                          onSelectionChanged:
                              (Set<OvertimePayType> newSelection) {
                                setState(() {
                                  _overtimePayType = newSelection.first;
                                });
                              },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _overtimeRateController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '残業手当',
                            border: const OutlineInputBorder(),
                            suffixText:
                                _overtimePayType == OvertimePayType.fixed
                                ? '円'
                                : '%',
                          ),
                          onChanged: (value) {
                            _overtimeRate = double.tryParse(value) ?? 25.0;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '深夜残業',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<OvertimePayType>(
                          segments: const [
                            ButtonSegment(
                              value: OvertimePayType.fixed,
                              label: Text('時給'),
                            ),
                            ButtonSegment(
                              value: OvertimePayType.percentage,
                              label: Text('%'),
                            ),
                          ],
                          selected: {_nightOvertimePayType},
                          onSelectionChanged:
                              (Set<OvertimePayType> newSelection) {
                                setState(() {
                                  _nightOvertimePayType = newSelection.first;
                                });
                              },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nightOvertimeRateController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '深夜手当',
                            border: const OutlineInputBorder(),
                            suffixText:
                                _nightOvertimePayType == OvertimePayType.fixed
                                ? '円'
                                : '%',
                          ),
                          onChanged: (value) {
                            _nightOvertimeRate = double.tryParse(value) ?? 25.0;
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _nightStartHour,
                                decoration: const InputDecoration(
                                  labelText: '深夜開始',
                                  border: OutlineInputBorder(),
                                ),
                                items: List.generate(24, (index) => index).map((
                                  hour,
                                ) {
                                  return DropdownMenuItem(
                                    value: hour,
                                    child: Text('$hour時'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _nightStartHour = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _nightEndHour,
                                decoration: const InputDecoration(
                                  labelText: '深夜終了',
                                  border: OutlineInputBorder(),
                                ),
                                items: List.generate(24, (index) => index).map((
                                  hour,
                                ) {
                                  return DropdownMenuItem(
                                    value: hour,
                                    child: Text('$hour時'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _nightEndHour = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '交通費',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _transportationFeeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '往復交通費',
                            border: OutlineInputBorder(),
                            suffixText: '円',
                          ),
                          onChanged: (value) {
                            _transportationFee = double.tryParse(value) ?? 0.0;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '休日勤務',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<OvertimePayType>(
                          segments: const [
                            ButtonSegment(
                              value: OvertimePayType.fixed,
                              label: Text('時給'),
                            ),
                            ButtonSegment(
                              value: OvertimePayType.percentage,
                              label: Text('%'),
                            ),
                          ],
                          selected: {_holidayPayType},
                          onSelectionChanged:
                              (Set<OvertimePayType> newSelection) {
                                setState(() {
                                  _holidayPayType = newSelection.first;
                                });
                              },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _holidayRateController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '休日手当',
                            border: const OutlineInputBorder(),
                            suffixText: _holidayPayType == OvertimePayType.fixed
                                ? '円'
                                : '%',
                          ),
                          onChanged: (value) {
                            _holidayRate = double.tryParse(value) ?? 0.0;
                          },
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: ['日', '月', '火', '水', '木', '金', '土']
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final label = entry.value;
                                return FilterChip(
                                  label: Text(label),
                                  selected: _holidayWeekdays.contains(index),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _holidayWeekdays.add(index);
                                      } else {
                                        _holidayWeekdays.remove(index);
                                      }
                                    });
                                  },
                                );
                              })
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveWorkplace,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
