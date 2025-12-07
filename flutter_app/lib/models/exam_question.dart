/// ExamQuestion Model
/// Represents exam questions protected by Oracle Label Security (OLS)
class ExamQuestion {
  final int? questionId;
  final String? subjectCode;
  final String questionText;
  final String? correctAnswer;
  final String? createdBy;
  final DateTime? createdDate;
  final int? olsLabel;
  final String? securityLabel; // "PUB", "INT:CS", "CONF:CS", etc.

  ExamQuestion({
    this.questionId,
    this.subjectCode,
    required this.questionText,
    this.correctAnswer,
    this.createdBy,
    this.createdDate,
    this.olsLabel,
    this.securityLabel,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      questionId: json['questionId'] is int
          ? json['questionId']
          : int.tryParse(json['questionId']?.toString() ?? ''),
      subjectCode: json['subjectCode'] as String?,
      questionText: json['questionText'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String?,
      createdBy: json['createdBy'] as String?,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString())
          : null,
      olsLabel: json['olsLabel'] is int
          ? json['olsLabel']
          : int.tryParse(json['olsLabel']?.toString() ?? ''),
      securityLabel: json['securityLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'subjectCode': subjectCode,
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'createdBy': createdBy,
      'createdDate': createdDate?.toIso8601String(),
      'olsLabel': olsLabel,
      'securityLabel': securityLabel,
    };
  }

  /// For creating a new question
  Map<String, dynamic> toCreateJson() {
    return {
      'subjectCode': subjectCode,
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'securityLabel': securityLabel,
    };
  }

  /// For updating an existing question
  Map<String, dynamic> toUpdateJson() {
    return {
      'subjectCode': subjectCode,
      'questionText': questionText,
      'correctAnswer': correctAnswer,
    };
  }

  ExamQuestion copyWith({
    int? questionId,
    String? subjectCode,
    String? questionText,
    String? correctAnswer,
    String? createdBy,
    DateTime? createdDate,
    int? olsLabel,
    String? securityLabel,
  }) {
    return ExamQuestion(
      questionId: questionId ?? this.questionId,
      subjectCode: subjectCode ?? this.subjectCode,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      olsLabel: olsLabel ?? this.olsLabel,
      securityLabel: securityLabel ?? this.securityLabel,
    );
  }

  /// Check if this is a public question
  bool get isPublic => securityLabel == 'PUB';

  /// Check if this is an internal question
  bool get isInternal => securityLabel?.startsWith('INT:') ?? false;

  /// Check if this is a confidential question
  bool get isConfidential => securityLabel?.startsWith('CONF:') ?? false;

  /// Get display name for security label
  String get securityLabelDisplay {
    switch (securityLabel) {
      case 'PUB':
        return 'Public';
      case 'INT:CS':
        return 'Internal (CS)';
      case 'INT:EE':
        return 'Internal (EE)';
      case 'CONF:CS':
        return 'Confidential (CS)';
      default:
        return securityLabel ?? 'Unknown';
    }
  }
}

