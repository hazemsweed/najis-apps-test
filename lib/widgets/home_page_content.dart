import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/HighSchoolScreen.dart';
import 'package:najih_education_app/screens/KindergartenScreen.dart';
import 'package:najih_education_app/screens/MiddleSchoolScreen.dart';
import 'package:najih_education_app/screens/PrimarySchoolScreen.dart';

typedef PageBuilder = Widget Function(String lang);

class HomePageContent extends StatelessWidget {
  final String lang;
  final Function(PageBuilder) openPage;
  const HomePageContent(
      {super.key, required this.lang, required this.openPage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _animatedHeroHeader(),
        const SizedBox(height: 24),
        _buildSectionHeader(),
        const SizedBox(height: 16),
        Expanded(child: _buildSectionGrid(context)),
      ],
    );
  }

  Widget _animatedHeroHeader() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 100),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff143290), Color(0xff4e58b4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(48),
            bottomRight: Radius.circular(48),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDecorativeIcon(Icons.auto_awesome_rounded),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    lang == 'en' ? "Najih Education" : "منصة ناجح التعليمية",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
                _buildDecorativeIcon(Icons.rocket_launch_rounded),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              lang == 'en'
                  ? "Learn anywhere, anytime.\nJoin top teachers & explore lessons."
                  : "تعلم من أي مكان، في أي وقت.\nانضم لأفضل المعلمين واستكشف الدروس.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeIcon(IconData icon) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xfff4bc43), Color(0xffffd700)],
        stops: [0.3, 1],
      ).createShader(bounds),
      child: Icon(icon, size: 36, color: Colors.white),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildHeaderLine()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              lang == 'en' ? "Explore Sections" : "تصفح الأقسام",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xff143290),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: _buildHeaderLine()),
        ],
      ),
    );
  }

  Widget _buildHeaderLine() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff143290).withOpacity(0.2),
            const Color(0xff143290),
            const Color(0xff143290).withOpacity(0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionGrid(BuildContext context) {
    final sections = [
      _HomeSection(lang == 'en' ? "High School" : "المدرسة الثانوية",
          Icons.school_outlined, const Color(0xff143290)),
      _HomeSection(lang == 'en' ? "Middle School" : "المدرسة الاعدادية",
          Icons.cast_for_education, const Color(0xff4e58b4)),
      _HomeSection(lang == 'en' ? "Primary School" : "المدرسة الابتدائية",
          Icons.menu_book_rounded, const Color(0xfff4bc43)),
      _HomeSection(lang == 'en' ? "Kindergarten" : "رياض الاطفال",
          Icons.child_care_rounded, const Color(0xff34c759)),
      _HomeSection(lang == 'en' ? "Exams" : "الامتحانات",
          Icons.assignment_turned_in_outlined, const Color(0xff5856d6)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: sections.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (_, i) {
          final s = sections[i];
          return _AnimatedHomeCard(
            title: s.title,
            icon: s.icon,
            color: s.color,
            onTap: () => _handleTap(context, s.title),
            index: i,
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, String title) {
    if ([
      'High School',
      'Middle School',
      'Primary School',
      'Kindergarten',
      'المدرسة الثانوية',
      'المدرسة الاعدادية',
      'المدرسة الابتدائية',
      'رياض الاطفال',
    ].contains(title)) {
      _showLessonTypeDialog(context, title);
    }
  }

  void _showLessonTypeDialog(BuildContext context, String section) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(lang == 'en' ? "Choose Lesson Type" : "اختر نوع الدرس"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _navigate(section, "Recorded");
              },
              icon: const Icon(Icons.play_circle),
              label: Text(lang == 'en' ? "Recorded Lessons" : "الدروس المسجلة"),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _navigate(section, "Stream");
              },
              icon: const Icon(Icons.live_tv),
              label: Text(lang == 'en' ? "Stream Lessons" : "الدروس المباشرة"),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(String section, String lessonType) {
    final e = lang == 'en';
    if (section == (e ? "High School" : "المدرسة الثانوية")) {
      openPage((l) => HighSchoolScreen(
          lang: l, lessonType: lessonType, openPage: openPage));
    } else if (section == (e ? "Middle School" : "المدرسة الاعدادية")) {
      openPage((l) => MiddleSchoolScreen(
          lang: l, lessonType: lessonType, openPage: openPage));
    } else if (section == (e ? "Primary School" : "المدرسة الابتدائية")) {
      openPage((l) => PrimarySchoolScreen(
          lang: l, lessonType: lessonType, openPage: openPage));
    } else if (section == (e ? "Kindergarten" : "رياض الاطفال")) {
      openPage((l) => KindergartenScreen(
          lang: l, lessonType: lessonType, openPage: openPage));
    }
  }
}

// ── Models & Components ─────────────────────────────────────────────
class _HomeSection {
  final String title;
  final IconData icon;
  final Color color;
  const _HomeSection(this.title, this.icon, this.color);
}

class _AnimatedHomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int index;

  const _AnimatedHomeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final safeValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: safeValue,
          child: Opacity(
            opacity: safeValue,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.white,
        elevation: 8,
        borderRadius: BorderRadius.circular(24),
        shadowColor: color.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 40, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: color,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(width: 24, height: 2, color: color.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
