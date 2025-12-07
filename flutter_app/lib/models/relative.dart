class Relative {
  final String? relativeId;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? contactAddress;
  final String? phoneNumber;
  final String? occupation;
  final String? email;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  Relative({
    this.relativeId,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.contactAddress,
    this.phoneNumber,
    this.occupation,
    this.email,
    this.createdDate,
    this.updatedDate,
  });

  factory Relative.fromJson(Map<String, dynamic> json) {
    return Relative(
      relativeId: json['relativeId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'] as String?,
      contactAddress: json['contactAddress'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      occupation: json['occupation'] as String?,
      email: json['email'] as String?,
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
      'relativeId': relativeId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'contactAddress': contactAddress,
      'phoneNumber': phoneNumber,
      'occupation': occupation,
      'email': email,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'contactAddress': contactAddress,
    };
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  Relative copyWith({
    String? relativeId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? contactAddress,
    String? phoneNumber,
    String? occupation,
    String? email,
  }) {
    return Relative(
      relativeId: relativeId ?? this.relativeId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      contactAddress: contactAddress ?? this.contactAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      occupation: occupation ?? this.occupation,
      email: email ?? this.email,
    );
  }
}

