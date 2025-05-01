import 'package:flutter/material.dart';
import 'package:najih_education_app/services/general_service.dart';
import 'package:provider/provider.dart';
import 'package:najih_education_app/screens/login_screen.dart';
import 'package:najih_education_app/screens/register_screen.dart';
import 'package:najih_education_app/screens/splash_screen.dart';
import 'package:najih_education_app/services/auth_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: const NajihApp(),
    ),
  );
}

class NajihApp extends StatelessWidget {
  const NajihApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Initialize GeneralService with the global context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GeneralService.init(context);
    });

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
