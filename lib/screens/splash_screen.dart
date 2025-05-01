import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:najih_education_app/screens/main_layout.dart';
import 'package:najih_education_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:najih_education_app/services/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      await AuthService().checkToken(context, token);
    } else {
      Provider.of<AuthState>(context, listen: false).setSession(
        user: null,
        token: null,
        expiry: null,
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
