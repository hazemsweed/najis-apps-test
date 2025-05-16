import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:najih_education_app/services/auth_state.dart';
import 'package:najih_education_app/services/general_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class MyStreamLessonsScreen extends StatefulWidget {
  final String lang;
  final VoidCallback? onBack;

  const MyStreamLessonsScreen({
    super.key,
    required this.lang,
    this.onBack,
  });

  @override
  State<MyStreamLessonsScreen> createState() => _MyStreamLessonsScreenState();
}

class _MyStreamLessonsScreenState extends State<MyStreamLessonsScreen> {
  late final GeneralService _gs;
  bool loading = true;
  List<dynamic> lessons = [];

  /* ─────────────────── DATA ─────────────────── */

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gs = GeneralService();
      _fetchLessons();
    });
  }

  Future<void> _fetchLessons() async {
    final auth = Provider.of<AuthState>(context, listen: false);
    final ids = List<String>.from(auth.user?['teachersLessonsIds'] ?? []);
    if (ids.isEmpty) return setState(() => loading = false);

    try {
      final res =
          await _gs.addItemLessons('studentsLessons/getUser/t-lessons', ids);
      if (!mounted) return;
      setState(() {
        lessons = res;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load lessons')));
    }
  }

  Future<void> _openLesson(String link) async {
    final auth = Provider.of<AuthState>(context, listen: false);
    if (!auth.isLoggedIn) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/login');
      return;
    }

    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $link';
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to open link')));
    }
  }

  Future<void> _trackLessonView(Map<String, dynamic> lesson) async {
    final auth = Provider.of<AuthState>(context, listen: false);
    final user = auth.user;
    if (user == null) return;

    await _gs.addItem('lesson-access-logs', {
      "user": {
        "_id": user['_id'],
        "name": user['name'],
        "username": user['username'],
      },
      "lesson": {
        "_id": lesson['_id'],
        "name": lesson['name'],
        "subject": {
          "_id": lesson['subjectId']['_id'],
          "name": lesson['subjectId']['name'],
          "level": lesson['subjectId']['level'],
          "lessonPrice": lesson['subjectId']['lessonPrice'],
        },
      },
      "teacher": {
        "_id": lesson['teacherId']['_id'],
        "name": lesson['teacherId']['name'],
        "username": lesson['teacherId']['email'],
      },
    });
  }

  /* ─────────────────── UI ─────────────────── */

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
                  const Positioned(
                      top: -40,
                      right: -20,
                      child: _BlurCircle(color: Color(0xFF143290))),
                  const Positioned(
                      bottom: -40,
                      left: -20,
                      child: _BlurCircle(color: Color(0xFFF4BC43))),
                  CustomScrollView(
                    slivers: [
                      _buildHeader(isAr),
                      if (lessons.isNotEmpty) _buildStats(isAr),
                      _buildGrid(),
                      const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  /* ───── HEADER & STATS ───── */

  SliverToBoxAdapter _buildHeader(bool isAr) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // back button
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.white,
                elevation: 2,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: widget.onBack ?? () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isAr ? Icons.arrow_forward : Icons.arrow_back,
                            color: const Color(0xFF143290), size: 20),
                        const SizedBox(width: 8),
                        Text(isAr ? 'العودة للاختيار' : 'Back to options',
                            style: const TextStyle(
                                color: Color(0xFF143290),
                                fontWeight: FontWeight.w500,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // title row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF143290),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.live_tv_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isAr ? 'الدروس المباشرة' : 'Stream Lessons',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF143290))),
                      const SizedBox(height: 4),
                      Text(
                          isAr
                              ? 'شاهد دروسك المباشرة هنا'
                              : 'Watch your stream lessons here',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildStats(bool isAr) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(isAr ? 'إجمالي الدروس' : 'Total Lessons',
                  '${lessons.length}', Icons.book),
              _buildStatItem(
                  isAr ? 'دروس مجانية' : 'Free Lessons',
                  '${lessons.where((l) => l['isFree'] == true).length}',
                  Icons.card_giftcard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF143290).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF143290), size: 20),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF143290))),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /* ───── GRID ───── */

  SliverPadding _buildGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverLayoutBuilder(
        builder: (_, __) {
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisSpacing: 24,
              crossAxisSpacing: 20,
              childAspectRatio: 1.35, // height equals content
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _LessonCard(
                item: lessons[index],
                lang: widget.lang,
                onWatch: () async {
                  await _trackLessonView(lessons[index]);
                  if (!mounted) return;
                  await _openLesson(lessons[index]['link']);
                },
              ),
              childCount: lessons.length,
            ),
          );
        },
      ),
    );
  }
}

/* ───── BLUR CIRCLE ───── */

class _BlurCircle extends StatelessWidget {
  final Color color;
  const _BlurCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration:
          BoxDecoration(color: color.withOpacity(.2), shape: BoxShape.circle),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: const SizedBox()),
    );
  }
}

/* ───── CARD ───── */

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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item['name'][lang] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF143290))),
                const SizedBox(height: 8),
                Text(item['description'][lang] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                _dateRow(isAr ? 'يبدأ:' : 'Start:', item['startDate']),
                _dateRow(isAr ? 'ينتهي:' : 'End:', item['endDate']),
                const SizedBox(height: 16), // tiny gap instead of huge spacer
                ElevatedButton(
                  onPressed: onWatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4BC43),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: Text(isAr ? 'شاهد الآن' : 'Watch now'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/$lang/stream_lessons/${item['subjectId']['_id']}/${item['teacherId']['_id']}',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF143290),
                    side: const BorderSide(color: Color(0xFF143290)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: Text(isAr ? 'الذهاب إلى المادة' : 'Go to subject'),
                ),
              ],
            ),
          ),
          if (item['isFree'] == true)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4BC43),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Text(isAr ? 'مجاني' : 'Free',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dateRow(String label, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey)),
          const SizedBox(width: 4),
          Text(date, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
