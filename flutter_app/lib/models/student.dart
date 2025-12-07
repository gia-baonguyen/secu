class Student {
  final String studentId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? classId;
  final String? studentStatus;

  Student({
    required this.studentId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.classId,
    this.studentStatus,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      address: json['contactAddress'] ?? json['address'], // Backend uses contactAddress
      classId: json['classId'],
      studentStatus: json['studentStatus']?.toString(),
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'contactAddress': address, // Backend uses contactAddress
      'classId': classId,
      'studentStatus': studentStatus,
    };
  }

  // Create a copy with updated fields for profile update
  Student copyWith({
    String? email,
    String? phoneNumber,
    String? address,
    String? studentStatus,
  }) {
    return Student(
      studentId: studentId,
      firstName: firstName,
      lastName: lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth,
      address: address ?? this.address,
      classId: classId,
      studentStatus: studentStatus ?? this.studentStatus,
    );
  }

  // Create JSON for update (only send fields that can be updated)
  Map<String, dynamic> toUpdateJson() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'contactAddress': address,
    };
  }
}

