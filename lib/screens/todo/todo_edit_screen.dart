import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/todo_model.dart';
import '../../models/subtask_model.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../../widgets/time_select_modal.dart';

class TodoEditScreen extends StatefulWidget {
  final DateTime selectedDate;
  final TodoModel? todo;

  const TodoEditScreen({super.key, required this.selectedDate, this.todo});

  @override
  State<TodoEditScreen> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends State<TodoEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _subtaskControllers = [];
  List<SubtaskModel> _subtasks = [];

  bool _isCompleted = false;
  bool _hasDueDate = false;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _isCompleted = widget.todo!.isCompleted;
      _subtasks = List.from(widget.todo!.subtasks);

      // サブタスク用のコントローラーを初期化
      for (final subtask in _subtasks) {
        final controller = TextEditingController(text: subtask.title);
        _subtaskControllers.add(controller);
      }

      _hasDueDate = widget.todo!.dueDate != null;
      if (_hasDueDate && widget.todo!.dueDate != null) {
        _dueDate = widget.todo!.dueDate;
        _dueTime = TimeOfDay.fromDateTime(widget.todo!.dueDate!);
      }
      _isPublic = widget.todo!.isPublic;
    } else {
      _dueDate = widget.selectedDate;
      _dueTime = const TimeOfDay(hour: 23, minute: 59);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSubtask() {
    setState(() {
      final controller = TextEditingController();
      _subtaskControllers.add(controller);
      _subtasks.add(
        SubtaskModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '',
          isCompleted: false,
        ),
      );
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
      _subtasks.removeAt(index);
    });
  }

  void _toggleSubtask(int index) {
    setState(() {
      _subtasks[index] = _subtasks[index].copyWith(
        isCompleted: !_subtasks[index].isCompleted,
      );
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    if (_dueDate == null) return;

    final result = await showTimeSelectModal(
      context,
      initialTime: _dueTime != null
          ? DateTime(
              _dueDate!.year,
              _dueDate!.month,
              _dueDate!.day,
              _dueTime!.hour,
              _dueTime!.minute,
            )
          : null,
      baseDate: _dueDate!,
      title: '締切時刻を選択',
      allowNextDay: false, // 日付部分を表示しない
    );

    if (result != null) {
      setState(() {
        _dueTime = TimeOfDay.fromDateTime(result);
      });
    }
  }

  Future<void> _saveTodo() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('タイトルを入力してください')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    DateTime? finalDueDate;
    if (_hasDueDate && _dueDate != null && _dueTime != null) {
      finalDueDate = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime!.hour,
        _dueTime!.minute,
      );
    }

    // サブタスクを更新
    final updatedSubtasks = <SubtaskModel>[];
    for (int i = 0; i < _subtasks.length; i++) {
      if (_subtaskControllers[i].text.isNotEmpty) {
        updatedSubtasks.add(
          _subtasks[i].copyWith(title: _subtaskControllers[i].text),
        );
      }
    }

    final todo = TodoModel(
      id: widget.todo?.id ?? '',
      userId: authProvider.user!.uid,
      title: _titleController.text,
      isCompleted: _isCompleted,
      subtasks: updatedSubtasks,
      dueDate: finalDueDate,
      isPublic: _isPublic,
      createdAt: widget.todo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.todo != null) {
        await dataProvider.updateTodo(todo);
      } else {
        await dataProvider.addTodo(todo);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }

  Future<void> _deleteTodo() async {
    if (widget.todo == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('このTODOを削除しますか？'),
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
      await dataProvider.deleteTodo(widget.todo!.id);
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
          widget.todo != null ? 'TODO編集' : 'TODO追加',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: widget.todo != null
            ? [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteTodo,
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
            // タイトルセクション
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
                          Icons.check_box,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'タイトル',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'やることを入力...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF0083DF)),
                      ),
                    ),
                    autofocus: true,
                    maxLines: null,
                    minLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // サブタスクセクション
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
                          Icons.list,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'サブタスク',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextButton.icon(
                          onPressed: _addSubtask,
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.blue,
                          ),
                          label: const Text(
                            '追加',
                            style: TextStyle(color: Colors.blue),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // サブタスクリスト
                  ...List.generate(_subtasks.length, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _subtasks[index].isCompleted,
                            onChanged: (value) => _toggleSubtask(index),
                            activeColor: Colors.green,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _subtaskControllers[index],
                              decoration: InputDecoration(
                                hintText: 'サブタスク ${index + 1}',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey[500]),
                              ),
                              style: TextStyle(
                                decoration: _subtasks[index].isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: _subtasks[index].isCompleted
                                    ? Colors.grey[600]
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => _removeSubtask(index),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 締切日時セクション
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
                          Icons.schedule,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '締切日時を設定',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Switch(
                        value: _hasDueDate,
                        onChanged: (value) {
                          setState(() {
                            _hasDueDate = value;
                            if (value && _dueDate == null) {
                              _dueDate = widget.selectedDate;
                              _dueTime = const TimeOfDay(hour: 23, minute: 59);
                            }
                          });
                        },
                        activeColor: Colors.orange,
                      ),
                    ],
                  ),
                  if (_hasDueDate && _dueDate != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: InkWell(
                        onTap: _selectDate,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '締切日',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    app_date_utils.DateUtils.formatDateDisplay(
                                      _dueDate!,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: InkWell(
                        onTap: _selectTime,
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '締切時刻',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    _dueTime != null
                                        ? app_date_utils.DateUtils.formatTime(
                                            DateTime(
                                              0,
                                              0,
                                              0,
                                              _dueTime!.hour,
                                              _dueTime!.minute,
                                            ),
                                          )
                                        : '未設定',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ステータス・公開セクション
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
                children: [
                  // 完了スイッチ
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SwitchListTile(
                      title: const Text('完了'),
                      subtitle: const Text('このTODOを完了済みにします'),
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      },
                      activeColor: Colors.green,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 公開スイッチ
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SwitchListTile(
                      title: const Text('公開する'),
                      subtitle: const Text('友達にTODOを公開します'),
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                      activeColor: Colors.blue,
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
                    color: Colors.green.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveTodo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
