import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'auth_state.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = "https://nserver.najih1.com/users";

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$_baseUrl/login");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password}),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      // persist token + update global state
      await _storage.write(key: 'token', value: body['accessToken']);
      AuthState().setUser(body['user']);
      return {'success': true};
    } else {
      return {'success': false, 'message': body['err'] ?? 'Login failed'};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    AuthState().logout();
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> user) async {
    final url = Uri.parse("$_baseUrl/signup");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return {'success': true};
    } else {
      return {'success': false, 'message': body['err'] ?? 'Signup failed'};
    }
  }
}
