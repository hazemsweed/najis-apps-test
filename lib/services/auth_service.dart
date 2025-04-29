import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = "http://localhost:1022/users";

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$_baseUrl/login");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final token = body['accessToken'];
      await _storage.write(key: 'token', value: token);
      return {'success': true, 'user': body['user']};
    } else {
      return {'success': false, 'message': body['err'].toString()};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final url = Uri.parse("$_baseUrl/signup");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      return {'success': true, 'userId': body['userId']};
    } else {
      return {'success': false, 'message': body['err'].toString()};
    }
  }
}
