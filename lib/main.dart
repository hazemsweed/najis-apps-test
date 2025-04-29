import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/login_screen.dart';
import 'package:najih_education_app/screens/main_layout.dart';
import 'package:najih_education_app/screens/register_screen.dart';

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

      // 1️⃣  set your “home” page
      home: const MainLayout(),

      // 2️⃣  register the extra pages we push by name
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}
