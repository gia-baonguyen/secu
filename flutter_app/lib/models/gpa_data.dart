class GpaData {
  final double? gpa;
  final double? totalCredits;
  final int? totalCourses;
  final String? gradeLevel;

  GpaData({
    this.gpa,
    this.totalCredits,
    this.totalCourses,
    this.gradeLevel,
  });

  factory GpaData.fromJson(Map<String, dynamic> json) {
    return GpaData(
      gpa: json['gpa']?.toDouble(),
      totalCredits: json['totalCredits']?.toDouble(),
      totalCourses: json['totalCourses'],
      gradeLevel: json['gradeLevel'],
    );
  }

  String get displayGpa {
    if (gpa != null) {
      return gpa!.toStringAsFixed(2);
    }
    return 'N/A';
  }
}

