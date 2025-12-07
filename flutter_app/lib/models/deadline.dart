class GradeSubmissionDeadline {
  final int? deadlineId;
  final String? semester;
  final int? academicYear;
  final DateTime? submissionDeadline;
  final String? isActive;
  final String? createdBy;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  GradeSubmissionDeadline({
    this.deadlineId,
    this.semester,
    this.academicYear,
    this.submissionDeadline,
    this.isActive,
    this.createdBy,
    this.createdDate,
    this.updatedDate,
  });

  factory GradeSubmissionDeadline.fromJson(Map<String, dynamic> json) {
    return GradeSubmissionDeadline(
      deadlineId: json['deadlineId'] as int?,
      semester: json['semester'] as String?,
      academicYear: json['academicYear'] as int?,
      submissionDeadline: json['submissionDeadline'] != null
          ? DateTime.tryParse(json['submissionDeadline'])
          : null,
      isActive: json['isActive'] as String?,
      createdBy: json['createdBy'] as String?,
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
      'deadlineId': deadlineId,
      'semester': semester,
      'academicYear': academicYear,
      'submissionDeadline': submissionDeadline?.toIso8601String(),
      'isActive': isActive,
      'createdBy': createdBy,
    };
  }

  bool get isActiveDeadline => isActive == 'Y';
  
  bool get isPastDeadline {
    if (submissionDeadline == null) return false;
    return DateTime.now().isAfter(submissionDeadline!);
  }

  bool get isBeforeDeadline => !isPastDeadline;

  String get semesterDisplay => 'Semester $semester - $academicYear';

  GradeSubmissionDeadline copyWith({
    int? deadlineId,
    String? semester,
    int? academicYear,
    DateTime? submissionDeadline,
    String? isActive,
    String? createdBy,
  }) {
    return GradeSubmissionDeadline(
      deadlineId: deadlineId ?? this.deadlineId,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      submissionDeadline: submissionDeadline ?? this.submissionDeadline,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

