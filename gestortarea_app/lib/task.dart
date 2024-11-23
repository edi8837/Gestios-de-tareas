class Task {
  int id;
  String name;
  String description;
  bool isCompleted;
  bool isDeleted;
  String? startDate; // Cambio a String
  String? endDate; // Cambio a String

  Task({
    required this.id,
    required this.name,
    required this.description,
    this.isCompleted = false,
    this.isDeleted = false,
    this.startDate,
    this.endDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      startDate: json['startDate'], // Ya no necesitamos parsear a DateTime
      endDate: json['endDate'], // Lo recibimos directamente como String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isCompleted': isCompleted,
      'isDeleted': isDeleted,
      'startDate': startDate, // Mandamos como String
      'endDate': endDate, // Mandamos como String
    };
  }

  @override
  String toString() {
    return 'Task(id: $id, name: $name, description: $description, isCompleted: $isCompleted, isDeleted: $isDeleted, startDate: $startDate, endDate: $endDate)';
  }
}
