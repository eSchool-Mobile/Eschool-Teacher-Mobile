class User {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? image;
  final String? fullName;
  final String? schoolNames;
  final String? role;
  final Student? student;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.image,
    this.fullName,
    this.schoolNames,
    this.role,
    this.student,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      image: json['image'] as String?,
      fullName: json['full_name'] as String?,
      schoolNames: json['school_names'] as String?,
      role: json['role'] as String?,
      student: json['student'] == null
          ? null
          : Student.fromJson(json['student'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'image': image,
        'full_name': fullName,
        'school_names': schoolNames,
        'role': role,
        'student': student?.toJson(),
      };
}

class Student {
  final int? id;
  final int? userId;
  final int? rollNumber;
  final String? firstName;
  final String? lastName;
  final String? fullName;

  Student({
    this.id,
    this.userId,
    this.rollNumber,
    this.firstName,
    this.lastName,
    this.fullName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      rollNumber: json['roll_number'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      fullName: json['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'roll_number': rollNumber,
        'first_name': firstName,
        'last_name': lastName,
        'full_name': fullName,
      };
}
