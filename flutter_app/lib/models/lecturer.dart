class Lecturer {
  final String lecturerId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? contactAddress;
  final String? departmentId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? academicDegree;
  final String? specialization;

  Lecturer({
    required this.lecturerId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.contactAddress,
    this.departmentId,
    this.dateOfBirth,
    this.gender,
    this.academicDegree,
    this.specialization,
  });

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      lecturerId: json['lecturerId'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      contactAddress: json['contactAddress'],
      departmentId: json['departmentId'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      gender: json['gender'],
      academicDegree: json['academicDegree'],
      specialization: json['specialization'],
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  Map<String, dynamic> toJson() {
    return {
      'lecturerId': lecturerId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'contactAddress': contactAddress,
      'departmentId': departmentId,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'academicDegree': academicDegree,
      'specialization': specialization,
    };
  }

  // Create a copy with updated fields for profile update
  Lecturer copyWith({
    String? email,
    String? phoneNumber,
    String? contactAddress,
  }) {
    return Lecturer(
      lecturerId: lecturerId,
      firstName: firstName,
      lastName: lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactAddress: contactAddress ?? this.contactAddress,
      departmentId: departmentId,
      dateOfBirth: dateOfBirth,
      gender: gender,
      academicDegree: academicDegree,
      specialization: specialization,
    );
  }

  // Create JSON for update (only send fields that can be updated)
  Map<String, dynamic> toUpdateJson() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'contactAddress': contactAddress,
    };
  }
}

