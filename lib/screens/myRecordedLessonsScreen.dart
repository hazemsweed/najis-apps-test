// lib/screens/recorded_lessons_screen.dart
import 'package:flutter/material.dart';
import 'package:najih_education_app/services/auth_state.dart';
import 'package:najih_education_app/services/general_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class MyRecordedLessonsScreen extends StatefulWidget {
  /// Current UI language – pass the same value you use elsewhere ('en' / 'ar')
  final String lang;
  final VoidCallback? onBack;

  const MyRecordedLessonsScreen({
    super.key,
    required this.lang,
    this.onBack,
  });

  @override
  State<MyRecordedLessonsScreen> createState() =>
      _MyRecordedLessonsScreenState();
}

class _MyRecordedLessonsScreenState extends State<MyRecordedLessonsScreen> {
  final GeneralService _gs = GeneralService();

  bool loading = true;
  List<dynamic> lessons = [];

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    final auth = AuthState(); // already cached after login
    final ids = List<String>.from(auth.user?['recorderLessonsIds'] ?? []);
    print(ids);
    if (ids.isEmpty) {
      setState(() => loading = false);
      return;
    }

    try {
      /// identical end-point & body shape to the Angular call
      final res = await _gs.addItemLessons(
        'studentsLessons/getUser/r-lessons',
        ids, // just the list, no jsonEncode
      );

      setState(() {
        lessons = res; // → List<Map<String, dynamic>>
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load lessons')),
      );
    }
  }

  void _openLesson(String link) async {
    // simple confirmation dialog (acts like MatDialog)
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(
          widget.lang == 'ar'
              ? 'سيتم فتح الدرس في متصفحك'
              : 'The lesson will open in your browser.',
        ),
        actions: [
          TextButton(
            child: Text(widget.lang == 'ar' ? 'فتح' : 'Open'),
            onPressed: () async {
              Navigator.pop(context);
              await launchUrl(Uri.parse(link),
                  mode: LaunchMode.externalApplication);
            },
          ),
          TextButton(
            child: Text(widget.lang == 'ar' ? 'إلغاء' : 'Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.lang == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // --------------------- content ------------------------
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            elevation: 2,
                            child: InkWell(
                              onTap:
                                  widget.onBack ?? () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(30),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isAr
                                          ? Icons.arrow_forward
                                          : Icons.arrow_back,
                                      color: const Color(0xFF143290),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isAr
                                          ? 'العودة للاختيار'
                                          : 'Back to options',
                                      style: const TextStyle(
                                        color: Color(0xFF143290),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Title Section
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF143290),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr
                                        ? 'الدروس المسجلة'
                                        : 'Recorded Lessons',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF143290),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAr
                                        ? 'يمكنك مشاهدة دروسك المسجلة هنا'
                                        : 'Watch all the lessons you own',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // lessons grid
                        LayoutBuilder(
                          builder: (_, constraints) {
                            return GridView.custom(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 500,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                mainAxisExtent: 280, // Estimated height
                              ),
                              childrenDelegate: SliverChildListDelegate(
                                lessons.map((item) {
                                  return _LessonCard(
                                    item: item,
                                    lang: widget.lang,
                                    onWatch: () => _openLesson(item['link']),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

//------------------ reusable widgets -------------------------------

class _BlurCircle extends StatelessWidget {
  final Color color;
  const _BlurCircle({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          color: color.withOpacity(.2),
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: const SizedBox(),
        ),
      );
}

class _LessonCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String lang;
  final VoidCallback onWatch;

  const _LessonCard({
    required this.item,
    required this.lang,
    required this.onWatch,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = lang == 'ar';
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // name
                Text(
                  item['name'][lang] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF143290),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  item['description'][lang] ?? '',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Dates
                _dateRow(isAr ? 'يبدأ:' : 'Start:', item['startDate']),
                _dateRow(isAr ? 'ينتهي:' : 'End:', item['endDate']),
                const SizedBox(height: 24),

                // Buttons
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4BC43),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: onWatch,
                      child: Text(isAr ? 'شاهد الآن' : 'Watch now'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF143290),
                        side: const BorderSide(color: Color(0xFF143290)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/${lang}/recorded_lessons/${item['subjectId']}',
                        );
                      },
                      child: Text(isAr ? 'الذهاب إلى المادة' : 'Go to subject'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // free ribbon
          if (item['isFree'] == true)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4BC43),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  isAr ? 'مجاني' : 'FREE',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dateRow(String lbl, String val) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          '$lbl $val',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
}
