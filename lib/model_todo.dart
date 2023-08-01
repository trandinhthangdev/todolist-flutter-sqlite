class ToDo {
  final int? id;
  final String status;
  final String label;
  final DateTime createdAt;
  ToDo({
    this.id,
    required this.status,
    required this.label,
    required this.createdAt
  });

  ToDo copy({
    int? id,
    String? status,
    String? label,
    DateTime? createdAt,
  }) =>
      ToDo(
        id: id ?? this.id,
        status: status ?? this.status,
        label: label ?? this.label,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'label': label,
    'createdAt': createdAt.toIso8601String()
  };

  ToDo.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        status = json['status'],
        label = json['label'],
        createdAt = DateTime.parse(json['createdAt'] as String);
  @override

  String toString() {
    return '"topic":'
        '{'
        '"id": $id, '
        '"status": $status, '
        '"label": $label, '
        '"createdAt": $createdAt, '
        '}';
  }
}