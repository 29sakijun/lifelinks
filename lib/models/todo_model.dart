import 'package:cloud_firestore/cloud_firestore.dart';
import 'subtask_model.dart';

class TodoModel {
  final String id;
  final String userId;
  final String title;
  final bool isCompleted;
  final List<SubtaskModel> subtasks; // サブタスクリスト
  final DateTime? dueDate; // 締切日時
  final bool isPublic; // 公開フラグ
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    this.subtasks = const [],
    this.dueDate,
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TodoModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // サブタスクを解析
    List<SubtaskModel> subtasks = [];
    if (data['subtasks'] != null) {
      final subtasksData = data['subtasks'] as List<dynamic>;
      subtasks = subtasksData
          .asMap()
          .entries
          .map(
            (entry) => SubtaskModel.fromMap(
              entry.value as Map<String, dynamic>,
              entry.key.toString(),
            ),
          )
          .toList();
    }

    return TodoModel(
      id: doc.id,
      userId: data['userId'],
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      subtasks: subtasks,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      isPublic: data['isPublic'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TodoModel copyWith({
    String? id,
    String? userId,
    String? title,
    bool? isCompleted,
    List<SubtaskModel>? subtasks,
    DateTime? dueDate,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      dueDate: dueDate ?? this.dueDate,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
