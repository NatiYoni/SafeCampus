import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/constants.dart';

class AdminStaffPage extends StatefulWidget {
  const AdminStaffPage({super.key});

  @override
  State<AdminStaffPage> createState() => _AdminStaffPageState();
}

class _AdminStaffPageState extends State<AdminStaffPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _foundUser;
  bool _isLoading = false;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final uniId = _searchController.text.trim();
    if (uniId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _foundUser = null;
    });

    try {
      final token = await _storage.read(key: 'access_token');
      final response = await _dio.get(
        '/admin/users/search', 
        queryParameters: {'university_id': uniId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      setState(() {
        _foundUser = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e is DioException && e.response?.statusCode == 404) {
          _errorMessage = "User not found";
        } else {
          _errorMessage = "Error searching user: $e";
        }
      });
    }
  }

  Future<void> _promoteUser(String email) async {
    setState(() => _isLoading = true);
    try {
      final token = await _storage.read(key: 'access_token');
      
      await _dio.post(
        '/admin/promote', 
        data: {
          "target_email": email
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User Promoted Successfully!")));
      setState(() {
        _foundUser = null; // Reset
        _searchController.clear();
        _isLoading = false;
      });
    } catch (e) {
       setState(() => _isLoading = false);
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Failed to promote: ${e is DioException ? e.response?.data['error'] ?? e.message : e}"))
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Staff')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Promote Student to Admin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search by University ID",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUser,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            if (_foundUser != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person, size: 40),
                  title: Text(_foundUser!['full_name'] ?? 'Unknown'),
                  subtitle: Text("${_foundUser!['email']}\nID: ${_foundUser!['university_id']}"),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () => _promoteUser(_foundUser!['email']),
                    child: const Text("Promote"),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
