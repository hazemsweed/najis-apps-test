import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/my_lessons_screen.dart';
import '../widgets/home_page_content.dart';
import 'package:najih_education_app/services/auth_state.dart';
import 'package:najih_education_app/services/auth_service.dart';

/// A function that builds a page for the current language
typedef PageBuilder = Widget Function(String lang);

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // language & navbar
  int _currentIndex = 0;
  String _lang = 'en';

  // holds a “recipe” for the current custom page
  PageBuilder? _customPageBuilder;

  // ────────────────────── lifecycle ──────────────────────
  @override
  void initState() {
    super.initState();
    AuthState().addListener(_authChanged); // rebuild when auth changes
  }

  void _authChanged() => setState(() {});

  @override
  void dispose() {
    AuthState().removeListener(_authChanged);
    super.dispose();
  }

  // ────────────────────── helpers ──────────────────────
  void _toggleLanguage() => setState(() => _lang = _lang == 'en' ? 'ar' : 'en');

  void _openCustomPage(PageBuilder builder) =>
      setState(() => _customPageBuilder = builder);

  void _goBackToMain() => setState(() => _customPageBuilder = null);

  bool get _loggedIn => AuthState().isLoggedIn;
  String get _userName => AuthState().user?['name'] ?? '';

  // ────────────────────── build ──────────────────────
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePageContent(lang: _lang, openPage: _openCustomPage),
      Center(child: MyLessonsScreen(lang: _lang)),
      const Center(child: Text("My Exams")),
      const Center(child: Text("Profile")),
    ];

    return Scaffold(
      // ────── AppBar ──────
      appBar: AppBar(
        leading: _customPageBuilder != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToMain,
              )
            : null,
        title: Text(_lang == 'en' ? "Najih Education" : "منصة ناجح التعليمية"),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: _lang == 'en' ? 'عربي' : 'English',
          ),
          if (_loggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: _lang == 'en' ? "Logout" : "تسجيل الخروج",
              onPressed: () async => await AuthService().logout(),
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: _lang == 'en' ? "Login" : "تسجيل الدخول",
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
        ],
      ),

      // ────── Body ──────
      body: Column(
        children: [
          if (_loggedIn)
            Container(
              width: double.infinity,
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(_lang == 'en'
                  ? "Welcome, $_userName!"
                  : "مرحبًا، $_userName!"),
            ),
          Expanded(
            child: _customPageBuilder?.call(_lang) ?? pages[_currentIndex],
          ),
        ],
      ),

      // ────── Bottom Nav (hidden on custom page) ──────
      bottomNavigationBar: _customPageBuilder == null
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: const Color(0xff143290),
              unselectedItemColor: Colors.grey,
              onTap: (i) => setState(() => _currentIndex = i),
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: _lang == 'en' ? "Home" : "الرئيسية"),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.play_circle),
                    label: _lang == 'en' ? "My Lessons" : "دروسي"),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.assignment),
                    label: _lang == 'en' ? "My Exams" : "امتحاناتي"),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.person),
                    label: _lang == 'en' ? "Profile" : "الملف الشخصي"),
              ],
            )
          : null,
    );
  }
}
