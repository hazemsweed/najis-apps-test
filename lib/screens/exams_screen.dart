import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/exam_screen.dart';
import 'package:najih_education_app/services/general_service.dart';

typedef PageBuilder = Widget Function(String lang);

class ExamsScreen extends StatefulWidget {
  final String lang;
  final Function(PageBuilder) openPage;

  const ExamsScreen({super.key, required this.lang, required this.openPage});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  bool loading = true;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    final res = await GeneralService().getItems('exams');
    setState(() {
      items = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.lang == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF143290),
          elevation: 0,
          title: Text(
            isAr ? 'الاختبارات' : 'Exams',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF143290)),
              )
            : Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(child: _headerLine()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            isAr ? 'اختبارات متاحة' : 'Available Exams',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF143290),
                            ),
                          ),
                        ),
                        Expanded(child: _headerLine()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _ExamCard(
                        exam: items[i],
                        lang: widget.lang,
                        index: i,
                        openPage: widget.openPage,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _headerLine() => Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFF143290).withOpacity(0.2),
            const Color(0xFF143290),
            const Color(0xFF143290).withOpacity(0.2),
          ]),
        ),
      );
}

class _ExamCard extends StatelessWidget {
  final Map<String, dynamic> exam;
  final String lang;
  final int index;
  final Function(PageBuilder) openPage;

  const _ExamCard({
    required this.exam,
    required this.lang,
    required this.index,
    required this.openPage,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = lang == 'ar';
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (_, value, child) {
        final safeValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: safeValue,
          child: Opacity(opacity: safeValue, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xfffefefe), Color(0xfff4f5ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -16,
              right: -16,
              child: Icon(Icons.assignment_turned_in,
                  size: 100, color: const Color(0xFFF4BC43).withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam['name'][lang] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF143290),
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exam['describtion'][lang] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${isAr ? 'المدة' : 'Time'}: ${exam['time']} ${isAr ? 'دقائق' : 'minutes'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${exam['questions'].length} ${isAr ? 'سؤال' : 'questions'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 20),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4BC43),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        openPage((l) => ExamScreen(
                              lang: l,
                              examId: exam['_id'],
                            ));
                      },
                      label: Text(
                        isAr ? 'بدء الاختبار' : 'Enter Exam',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
