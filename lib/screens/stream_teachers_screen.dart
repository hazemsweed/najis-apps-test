import 'package:flutter/material.dart';
import 'package:najih_education_app/services/general_service.dart';
import 'stream_lessons_screen.dart';

typedef PageBuilder = Widget Function(String lang);

class StreamTeachersScreen extends StatefulWidget {
  final String subjectId;
  final String lang;
  final Function(PageBuilder) openPage;

  const StreamTeachersScreen({
    super.key,
    required this.subjectId,
    required this.lang,
    required this.openPage,
  });

  @override
  State<StreamTeachersScreen> createState() => _StreamTeachersScreenState();
}

class _StreamTeachersScreenState extends State<StreamTeachersScreen> {
  final GeneralService _gs = GeneralService();
  bool loading = true;

  late String _lang = widget.lang;
  Map<String, dynamic>? item; // {name, level, lessonPrice, teachersIds: []}

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      final data = await _gs.getItem(
          'apply_teacher/getTeachersForWeb', widget.subjectId);
      setState(() {
        item = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching teachers: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xff143290))),
      );
    }
    if (item == null) {
      return Scaffold(
        body:
            Center(child: Text(_lang == 'en' ? 'Error' : 'حدث خطأ في التحميل')),
      );
    }

    final teachers = item!['teachersIds'] as List<dynamic>;

    return Scaffold(
      body: Directionality(
        textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
              // subject header
              Text(
                "${item!['name'][_lang]} / ${item!['level'][_lang]}",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff143290)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // teachers grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teachers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .85,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20),
                itemBuilder: (_, idx) {
                  final t = teachers[idx];
                  return _TeacherCard(
                    lang: _lang,
                    teacher: t,
                    lessonPrice: item!['lessonPrice'],
                    onTap: () => widget.openPage(
                      (l) => StreamLessonsScreen(
                        subjectId: widget.subjectId,
                        teacherId: t['_id'],
                        lang: l,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final String lang;
  final dynamic teacher;
  final dynamic lessonPrice;
  final VoidCallback onTap;

  const _TeacherCard(
      {required this.lang,
      required this.teacher,
      required this.lessonPrice,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // avatar
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xfff4bc43),
                backgroundImage: teacher['image']?['url'] != null
                    ? NetworkImage(teacher['image']['url'])
                    : null,
                child: teacher['image']?['url'] == null
                    ? const Icon(Icons.person, size: 36, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(teacher['name'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff143290))),
              const SizedBox(height: 8),
              Text(
                "${lang == 'en' ? 'Price' : 'السعر'}: $lessonPrice EGP",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
