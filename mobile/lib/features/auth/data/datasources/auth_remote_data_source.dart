import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> register(String email, String password, String fullName, String phoneNumber, String universityId);
  Future<void> verifyEmail(String email, String code);
  Future<void> resendVerification(String email);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;
  final FlutterSecureStorage secureStorage;

  AuthRemoteDataSourceImpl({required this.client, required this.secureStorage});

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await client.post(
      '/login',
      data: {
        "email": email,
        "password": password
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      await secureStorage.write(key: 'access_token', value: data['access_token']);
      await secureStorage.write(key: 'refresh_token', value: data['refresh_token']);
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception('Failed to login');
    }
  }

  @override
  Future<void> register(String email, String password, String fullName, String phoneNumber, String universityId) async {
    final response = await client.post(
      '/register',
      data: {
        "email": email,
        "password": password,
        "full_name": fullName,
        "phone_number": phoneNumber,
        "university_id": universityId,
      },
    );

    if (response.statusCode != 201) { // Assuming 201 Created
       throw Exception(response.data['error'] ?? 'Failed to register');
    }
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    final response = await client.post(
      '/verify-email',
      data: {
        "email": email,
        "code": code,
      },
    );

    if (response.statusCode != 200) {
       throw Exception(response.data['error'] ?? 'Failed to verify email');
    }
  }

  @override
  Future<void> resendVerification(String email) async {
    final response = await client.post(
      '/resend-verification',
      data: {
        "email": email,
      },
    );

    if (response.statusCode != 200) {
       throw Exception(response.data['error'] ?? 'Failed to resend verification');
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
  }
}
