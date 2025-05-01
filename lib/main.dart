import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:najih_education_app/screens/login_screen.dart';
import 'package:najih_education_app/screens/main_layout.dart';
import 'package:najih_education_app/screens/register_screen.dart';
import 'package:najih_education_app/services/auth_service.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const NajihApp());
}

class NajihApp extends StatelessWidget {
  const NajihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Najih Education',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}
