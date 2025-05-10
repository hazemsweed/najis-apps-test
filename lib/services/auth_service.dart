import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:najih_education_app/constants/api_config.dart';
import 'package:provider/provider.dart';
import 'auth_state.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(
      BuildContext context, String username, String password) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/login");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password}),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      await _storage.write(key: 'token', value: body['accessToken']);

      Provider.of<AuthState>(context, listen: false).setSession(
        user: body['user'],
        token: body['accessToken'],
        expiry: DateTime.now().add(const Duration(hours: 24)),
      );
      return {'success': true};
    } else {
      return {'success': false, 'message': body['err'] ?? 'Login failed'};
    }
  }

  Future<void> logout(BuildContext context) async {
    await _storage.delete(key: 'token');
    Provider.of<AuthState>(context, listen: false).logout();
  }

  Future<bool> checkToken(BuildContext context, String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/check/JWT");
    final res = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['accessToken'] != null) {
        await _storage.write(key: 'token', value: body['accessToken']);
        Provider.of<AuthState>(context, listen: false).setSession(
          user: body['user'],
          token: body['accessToken'],
          expiry: DateTime.now().add(const Duration(hours: 24)),
        );
        return true;
      }
    }

    return false;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> user) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/signup");
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
