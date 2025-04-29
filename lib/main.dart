import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/main_layout.dart';

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
      home: const MainLayout(),
    );
  }
}
