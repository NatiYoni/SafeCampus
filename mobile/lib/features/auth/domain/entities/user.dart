import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String universityId;
  final bool isVerified;
  final String role; // Added role field
  final Profile? profile; 

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.universityId,
    required this.isVerified,
    required this.role,
    this.profile,
  });

  @override
  List<Object?> get props => [id, email, fullName, phoneNumber, universityId, isVerified, role, profile];
}

class Profile extends Equatable {
  final String bloodType;
  final List<String> allergies;
  final List<String> medicalConditions;
  final List<String> medications;

  const Profile({
    required this.bloodType,
    required this.allergies,
    required this.medicalConditions,
    required this.medications,
  });

  @override
  List<Object?> get props => [bloodType, allergies, medicalConditions, medications];
}
