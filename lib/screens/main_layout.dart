import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/my_lessons_screen.dart';
import '../widgets/home_page_content.dart';

/// A function that builds a page for the current language
typedef PageBuilder = Widget Function(String lang);

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // navbar & language
  int _currentIndex = 0;
  String _lang = 'en';

  // holds the *recipe* (not the built widget) for the current custom page
  PageBuilder? _customPageBuilder;

  // simulated auth
  bool _isLoggedIn = false;
  String _userName = "Hazem";
  String _role = "student";

  // ────────────────────── helpers ──────────────────────
  void _toggleLanguage() => setState(() {
        _lang = _lang == 'en' ? 'ar' : 'en';
        /*  no other code needed – build() below will call
            _customPageBuilder again with the new _lang    */
      });

  void _openCustomPage(PageBuilder builder) =>
      setState(() => _customPageBuilder = builder);

  void _goBackToMain() => setState(() => _customPageBuilder = null);

  void _toggleLogin() => setState(() => _isLoggedIn = !_isLoggedIn);

  @override
  Widget build(BuildContext context) {
    // standard tab pages
    final List<Widget> _pages = [
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
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _toggleLogin,
              tooltip: _lang == 'en' ? "Logout" : "تسجيل الخروج",
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: _toggleLogin,
              tooltip: _lang == 'en' ? "Login" : "تسجيل الدخول",
            ),
        ],
      ),

      // ────── Body ──────
      body: Column(
        children: [
          if (_isLoggedIn)
            Container(
              width: double.infinity,
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                _lang == 'en' ? "Welcome, $_userName!" : "مرحبًا، $_userName!",
              ),
            ),
          Expanded(
            child: _customPageBuilder?.call(_lang) ??
                _pages[_currentIndex], // build on every rebuild
          ),
        ],
      ),

      // ────── Bottom Nav (hide on custom page) ──────
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
}
