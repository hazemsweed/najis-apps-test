import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/myRecordedLessonsScreen.dart';
import 'package:najih_education_app/screens/myStreamLessonsScreen.dart';

typedef PageBuilder = Widget Function(String lang);

class MyLessonsScreen extends StatefulWidget {
  final String lang;
  const MyLessonsScreen({super.key, required this.lang});

  @override
  State<MyLessonsScreen> createState() => _MyLessonsScreenState();
}

class _MyLessonsScreenState extends State<MyLessonsScreen> {
  String selected = 'none';
  PageBuilder? _customPageBuilder;

  void _openCustomPage(PageBuilder builder) {
    setState(() => _customPageBuilder = builder);
  }

  void _goBackToMain() {
    setState(() {
      _customPageBuilder = null;
      selected = 'none';
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      body: Column(
        children: [
          // Only show header if no custom page is active
          if (_customPageBuilder == null) ...[
            _buildHeroHeader(lang),
            const SizedBox(height: 24),
          ],
          if (_customPageBuilder != null)
            // ✅ if a custom subpage is active (like MyRecordedLessonsScreen)
            Expanded(
              child: Stack(
                children: [
                  _customPageBuilder!(lang),
                  // Back button
                ],
              ),
            )
          else if (selected == 'none')
            // ✅ initial card selection view
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildLessonCard(
                    context,
                    title: lang == 'en' ? "Recorded Lessons" : "الدروس المسجلة",
                    icon: Icons.play_circle_fill,
                    color: const Color(0xfff4bc43),
                    onTap: () {
                      setState(() {
                        selected = 'recorded';
                        _customPageBuilder = (l) => MyRecordedLessonsScreen(
                              lang: l,
                              onBack: _goBackToMain,
                            );
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLessonCard(
                    context,
                    title: lang == 'en' ? "Stream Lessons" : "الدروس المباشرة",
                    icon: Icons.live_tv_rounded,
                    color: const Color(0xff143290),
                    onTap: () {
                      setState(() {
                        selected = 'stream';
                        _customPageBuilder = (l) => MyStreamLessonsScreen(
                              lang: l,
                              onBack: _goBackToMain,
                            );
                      });
                    },
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildHeroHeader(String lang) {
    String getTitle() {
      if (_customPageBuilder != null) {
        if (selected == 'recorded') {
          return lang == 'en' ? 'Recorded Lessons' : 'الدروس المسجلة';
        } else if (selected == 'stream') {
          return lang == 'en' ? 'Stream Lessons' : 'الدروس المباشرة';
        }
      }
      return lang == 'en' ? 'My Lessons' : 'دروسي';
    }

    String getSubtitle() {
      if (_customPageBuilder != null) {
        if (selected == 'recorded') {
          return lang == 'en'
              ? "Watch all the lessons you own"
              : "يمكنك مشاهدة دروسك المسجلة هنا";
        } else if (selected == 'stream') {
          return lang == 'en'
              ? "Attend your live lessons here"
              : "تابع دروسك المباشرة من هنا";
        }
      }
      return lang == 'en'
          ? "Choose the type of lessons to view"
          : "اختر نوع الدروس لعرضها";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff143290), Color(0xff4e58b4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Text(
            getTitle(),
            style: const TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (getSubtitle().isNotEmpty)
            Text(
              getSubtitle(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      builder: (context, value, child) {
        final opacity = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: opacity,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
