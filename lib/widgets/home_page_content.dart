import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/HighSchoolScreen.dart';
import 'package:najih_education_app/screens/KindergartenScreen.dart';
import 'package:najih_education_app/screens/MiddleSchoolScreen.dart';
import 'package:najih_education_app/screens/PrimarySchoolScreen.dart';

import '../screens/recorded_lessons_screen.dart'; // needed for builders

typedef PageBuilder = Widget Function(String lang);

class HomePageContent extends StatelessWidget {
  final String lang;
  final Function(PageBuilder) openPage; // <-- updated type

  const HomePageContent(
      {super.key, required this.lang, required this.openPage});

  @override
  Widget build(BuildContext context) {
    final List<_HomeSection> sections = [
      _HomeSection(lang == 'en' ? "High School" : "المدرسة الثانوية",
          Icons.school_outlined),
      _HomeSection(lang == 'en' ? "Middle School" : "المدرسة الاعدادية",
          Icons.cast_for_education),
      _HomeSection(lang == 'en' ? "Primary School" : "المدرسة الابتدائية",
          Icons.menu_book_rounded),
      _HomeSection(lang == 'en' ? "Kindergarten" : "رياض الاطفال",
          Icons.child_care_rounded),
      _HomeSection(lang == 'en' ? "Exams" : "الامتحانات",
          Icons.assignment_turned_in_outlined),
    ];

    return Column(
      children: [
        _buildHeroHeader(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              lang == 'en' ? "Explore Sections" : "تصفح الأقسام",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff143290)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: sections.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final section = sections[index];
                return _HomeCard(
                  title: section.title,
                  icon: section.icon,
                  onTap: () {
                    if ([
                          "High School",
                          "Middle School",
                          "Primary School",
                          "Kindergarten"
                        ].contains(section.title) ||
                        [
                          "المدرسة الثانوية",
                          "المدرسة الاعدادية",
                          "المدرسة الابتدائية",
                          "رياض الاطفال"
                        ].contains(section.title)) {
                      _showLessonTypeDialog(context, section.title);
                    } else {
                      // TODO: Handle other sections
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ───── hero header ─────
  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff143290), Color(0xfff4bc43)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            lang == 'en' ? "Najih Education" : "منصة ناجح التعليمية",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lang == 'en'
                ? "Learn anywhere, anytime.\nJoin top teachers & explore lessons."
                : "تعلم من أي مكان، في أي وقت.\nانضم لأفضل المعلمين واستكشف الدروس.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ───── dialog ─────
  void _showLessonTypeDialog(BuildContext context, String sectionTitle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(lang == 'en' ? "Choose Lesson Type" : "اختر نوع الدرس"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToSection(context, sectionTitle, "Recorded");
                },
                icon: const Icon(Icons.play_circle),
                label:
                    Text(lang == 'en' ? "Recorded Lessons" : "الدروس المسجلة"),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToSection(context, sectionTitle, "Stream");
                },
                icon: const Icon(Icons.live_tv),
                label:
                    Text(lang == 'en' ? "Stream Lessons" : "الدروس المباشرة"),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───── section navigation ─────
  void _navigateToSection(
      BuildContext context, String sectionTitle, String lessonType) {
    if (sectionTitle == (lang == 'en' ? "High School" : "المدرسة الثانوية")) {
      openPage((l) => HighSchoolScreen(
          lang: l, lessonType: lessonType, openPage: openPage));
    } else if (sectionTitle ==
        (lang == 'en' ? "Middle School" : "المدرسة الاعدادية")) {
      openPage((l) => MiddleSchoolScreen(
            lang: l,
            lessonType: lessonType,
            openPage: openPage,
          ));
    } else if (sectionTitle ==
        (lang == 'en' ? "Primary School" : "المدرسة الابتدائية")) {
      openPage((l) => PrimarySchoolScreen(
            lang: l,
            lessonType: lessonType,
            openPage: openPage,
          ));
    } else if (sectionTitle ==
        (lang == 'en' ? "Kindergarten" : "رياض الاطفال")) {
      openPage((l) => KindergartenScreen(
            lang: l,
            lessonType: lessonType,
            openPage: openPage,
          ));
    }
  }
}

// ───────────────── helper widgets ─────────────────
class _HomeSection {
  final String title;
  final IconData icon;
  _HomeSection(this.title, this.icon);
}

class _HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeCard(
      {super.key,
      required this.title,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xff143290), Color(0xfff4bc43)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xff143290)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
