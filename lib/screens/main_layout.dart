import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:najih_education_app/screens/my_lessons_screen.dart';
import 'package:najih_education_app/services/auth_state.dart';
import 'package:najih_education_app/services/auth_service.dart';
import '../widgets/home_page_content.dart';
import 'package:najih_education_app/screens/profile_screen.dart';

typedef PageBuilder = Widget Function(String lang);

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  String _lang = 'en';
  PageBuilder? _customPageBuilder;

  void _toggleLanguage() => setState(() => _lang = _lang == 'en' ? 'ar' : 'en');
  void _openCustomPage(PageBuilder builder) =>
      setState(() => _customPageBuilder = builder);
  void _goBackToMain() => setState(() => _customPageBuilder = null);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final loggedIn = auth.isLoggedIn;
    final userName = auth.user?['name'] ?? '';

    final pages = [
      HomePageContent(lang: _lang, openPage: _openCustomPage),
      loggedIn ? MyLessonsScreen(lang: _lang) : _requireLogin("My Lessons"),
      loggedIn
          ? const Center(child: Text("My Exams"))
          : _requireLogin("My Exams"),
      loggedIn ? ProfileScreen(lang: _lang) : _requireLogin("Profile"),
    ];

    return Scaffold(
      // ---------- APP BAR ----------
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xff143290),
        leading: _customPageBuilder != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _goBackToMain,
              )
            : null,
        title: Text(
          _lang == 'en' ? "Najih Education" : "منصة ناجح التعليمية",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // language
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: _lang == 'en' ? 'عربي' : 'English',
            onPressed: _toggleLanguage,
          ),
          // auth
          if (loggedIn)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: _lang == 'en' ? "Logout" : "تسجيل الخروج",
              onPressed: () async => await AuthService().logout(context),
            )
          else
            IconButton(
              icon: const Icon(Icons.login, color: Colors.white),
              tooltip: _lang == 'en' ? "Login" : "تسجيل الدخول",
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
        ],
      ),

      body: Column(
        children: [
          if (loggedIn)
            Container(
              width: double.infinity,
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                  _lang == 'en' ? "Welcome, $userName!" : "مرحبًا، $userName!"),
            ),
          Expanded(
            child: _customPageBuilder?.call(_lang) ?? pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: _customPageBuilder == null
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: const Color(0xff143290),
              unselectedItemColor: Colors.grey,
              onTap: (i) => setState(() => _currentIndex = i),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: _lang == 'en' ? "Home" : "الرئيسية",
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.play_circle),
                  label: _lang == 'en' ? "My Lessons" : "دروسي",
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.assignment),
                  label: _lang == 'en' ? "My Exams" : "امتحاناتي",
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: _lang == 'en' ? "Profile" : "الملف الشخصي",
                ),
              ],
            )
          : null,
    );
  }

  Widget _requireLogin(String pageName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_lang == 'en'
              ? "$pageName requires login"
              : "صفحة $pageName تتطلب تسجيل الدخول"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text(_lang == 'en' ? "Login" : "تسجيل الدخول"),
          ),
        ],
      ),
    );
  }
}
