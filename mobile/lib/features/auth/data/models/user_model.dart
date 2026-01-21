import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.phoneNumber,
    required super.universityId,
    required super.isVerified,
    required super.role,
    super.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      universityId: json['university_id'],
      isVerified: json['is_verified'] ?? false,
      role: json['role'] ?? 'student', // Default to student
      profile: json['profile'] != null ? ProfileModel.fromJson(json['profile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'university_id': universityId,
      'is_verified': isVerified,
      'role': role,
      'profile': profile != null ? (profile as ProfileModel).toJson() : null,
    };
  }
}

class ProfileModel extends Profile {
  const ProfileModel({
    required super.bloodType,
    required super.allergies,
    required super.medicalConditions,
    required super.medications,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      bloodType: json['blood_type'] ?? '',
      allergies: List<String>.from(json['allergies'] ?? []),
      medicalConditions: List<String>.from(json['medical_conditions'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blood_type': bloodType,
      'allergies': allergies,
      'medical_conditions': medicalConditions,
      'medications': medications,
    };
  }
}
