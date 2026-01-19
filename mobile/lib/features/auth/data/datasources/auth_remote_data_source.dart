import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<User> login(String email, String password) async {
    final response = await client.post(
      '/login',
      data: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    if (response.statusCode == 200) {
      final data = response.data['user'];
      return User(
        id: data['id'],
        email: data['email'],
        fullName: data['full_name'],
        phoneNumber: data['phone_number'],
        universityId: data['university_id'],
        profile: Profile(
          bloodType: data['profile']['blood_type'],
          allergies: List<String>.from(data['profile']['allergies'] ?? []),
          medicalConditions: List<String>.from(data['profile']['medical_conditions'] ?? []),
          medications: List<String>.from(data['profile']['medications'] ?? []),
        ),
      );
    } else {
      throw Exception('Login Failed');
    }
  }
}
