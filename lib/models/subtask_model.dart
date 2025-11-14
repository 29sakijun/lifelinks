class SubtaskModel {
  final String id;
  final String title;
  final bool isCompleted;

  SubtaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory SubtaskModel.fromMap(Map<String, dynamic> data, String id) {
    return SubtaskModel(
      id: id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'isCompleted': isCompleted};
  }

  SubtaskModel copyWith({String? id, String? title, bool? isCompleted}) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}















