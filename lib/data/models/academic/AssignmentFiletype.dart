class AssignmentFileType {
  final int id;
  final String name;
  bool isSelected;

  AssignmentFileType({
    required this.id, 
    required this.name,
    this.isSelected = false,
  });

  factory AssignmentFileType.fromJson(Map<String, dynamic> json) {
    return AssignmentFileType(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
    );
  }
}
