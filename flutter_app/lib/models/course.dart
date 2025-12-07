class Course {
  final String? courseId;
  final String? courseName;
  final int? credits;
  final String? departmentId;
  final String? courseType;
  final String? prerequisiteCourseId;
  final String? description;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  Course({
    this.courseId,
    this.courseName,
    this.credits,
    this.departmentId,
    this.courseType,
    this.prerequisiteCourseId,
    this.description,
    this.createdDate,
    this.updatedDate,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['courseId'] as String?,
      courseName: json['courseName'] as String?,
      credits: json['credits'] as int?,
      departmentId: json['departmentId'] as String?,
      courseType: json['courseType'] as String?,
      prerequisiteCourseId: json['prerequisiteCourseId'] as String?,
      description: json['description'] as String?,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'])
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.tryParse(json['updatedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'credits': credits,
      'departmentId': departmentId,
      'courseType': courseType,
      'prerequisiteCourseId': prerequisiteCourseId,
      'description': description,
    };
  }

  bool get isMandatory => courseType == 'Mandatory';
  bool get isElective => courseType == 'Elective';
  bool get hasPrerequisite => prerequisiteCourseId != null && prerequisiteCourseId!.isNotEmpty;

  Course copyWith({
    String? courseId,
    String? courseName,
    int? credits,
    String? departmentId,
    String? courseType,
    String? prerequisiteCourseId,
    String? description,
  }) {
    return Course(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      credits: credits ?? this.credits,
      departmentId: departmentId ?? this.departmentId,
      courseType: courseType ?? this.courseType,
      prerequisiteCourseId: prerequisiteCourseId ?? this.prerequisiteCourseId,
      description: description ?? this.description,
    );
  }
}

