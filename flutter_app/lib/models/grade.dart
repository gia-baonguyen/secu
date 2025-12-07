class Grade {
  final int? gradeId;
  final int enrollmentId;
  final double? midtermScore;
  final double? finalScore;
  final double? totalScore;
  final String? letterGrade;
  final String? gradeStatus;
  final String? submittedBy;
  final DateTime? submittedDate;
  final String? courseName;

  Grade({
    this.gradeId,
    required this.enrollmentId,
    this.midtermScore,
    this.finalScore,
    this.totalScore,
    this.letterGrade,
    this.gradeStatus,
    this.submittedBy,
    this.submittedDate,
    this.courseName,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    // Handle gradeId - can be int, String, or null
    int? parseGradeId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Handle enrollmentId - can be int or String (backend returns String)
    int parseEnrollmentId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Handle scores - can be int, double, String, or null
    double? parseScore(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Grade(
      gradeId: parseGradeId(json['gradeId']),
      enrollmentId: parseEnrollmentId(json['enrollmentId']),
      midtermScore: parseScore(json['midtermScore']),
      finalScore: parseScore(json['finalScore']),
      totalScore: parseScore(json['totalScore']),
      letterGrade: json['letterGrade']?.toString(),
      gradeStatus: json['gradeStatus']?.toString(),
      submittedBy: json['submittedBy']?.toString(),
      submittedDate: json['submittedDate'] != null
          ? DateTime.tryParse(json['submittedDate'].toString())
          : null,
      courseName: json['courseName']?.toString(),
    );
  }

  String get displayScore {
    if (totalScore != null) {
      return totalScore!.toStringAsFixed(1);
    }
    return 'N/A';
  }

  Map<String, dynamic> toJson() {
    return {
      'gradeId': gradeId,
      'enrollmentId': enrollmentId,
      'midtermScore': midtermScore,
      'finalScore': finalScore,
      'totalScore': totalScore,
      'letterGrade': letterGrade,
      'gradeStatus': gradeStatus,
      'submittedBy': submittedBy,
      'submittedDate': submittedDate?.toIso8601String(),
    };
  }

  // Create a copy with updated fields for grade update
  Grade copyWith({
    double? midtermScore,
    double? finalScore,
  }) {
    return Grade(
      gradeId: gradeId,
      enrollmentId: enrollmentId,
      midtermScore: midtermScore ?? this.midtermScore,
      finalScore: finalScore ?? this.finalScore,
      totalScore: totalScore,
      letterGrade: letterGrade,
      gradeStatus: gradeStatus,
      submittedBy: submittedBy,
      submittedDate: submittedDate,
      courseName: courseName,
    );
  }

  // Create JSON for update (only send fields that can be updated)
  Map<String, dynamic> toUpdateJson() {
    return {
      'midtermScore': midtermScore,
      'finalScore': finalScore,
    };
  }
}

