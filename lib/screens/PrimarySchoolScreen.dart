import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/recorded_lessons_screen.dart';
import 'package:najih_education_app/screens/stream_teachers_screen.dart';
import 'package:najih_education_app/services/general_service.dart';

typedef PageBuilder = Widget Function(String lang);

class PrimarySchoolScreen extends StatefulWidget {
  final String lang;
  final String lessonType;
  final Function(PageBuilder) openPage;

  const PrimarySchoolScreen({
    super.key,
    required this.lang,
    required this.lessonType,
    required this.openPage,
  });

  @override
  State<PrimarySchoolScreen> createState() => _PrimarySchoolScreenState();
}

class _PrimarySchoolScreenState extends State<PrimarySchoolScreen> {
  bool loading = true;
  List<dynamic> items = [];
  List<ClassGroup> classes = [];
  final GeneralService _generalService = GeneralService();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final collection = widget.lessonType.toLowerCase() == 'recorded'
          ? 'r_subjects'
          : 't_subjects';

      items = await _generalService
          .getItemsWithQuery(collection, {"type": "Primary"});

      populateClasses();
    } catch (e) {
      debugPrint('Error fetching primary data: $e');
      setState(() => loading = false);
    }
  }

  void populateClasses() {
    classes = List.generate(6, (i) {
      final n = i + 1;
      return ClassGroup(
        title: {
          "en": "Grade $n",
          "ar": "الصف $n الابتدائي",
        },
        items: items.where((item) => item["class"] == n).toList(),
      );
    });
    setState(() => loading = false);
  }

  String getPageType() {
    return widget.lessonType.toLowerCase() == "recorded"
        ? (widget.lang == 'en' ? "Recorded Lessons" : "الدروس المسجلة")
        : (widget.lang == 'en' ? "Stream Lessons" : "الدروس المباشرة");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff143290)))
          : Directionality(
              textDirection:
                  widget.lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: classes.map(_buildClassCard).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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
            widget.lang == 'en' ? "Primary School" : "المدرسة الابتدائية",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            getPageType(),
            style: const TextStyle(
              color: Color(0xfff4bc43),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(ClassGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff143290), Color(0xfff4bc43)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              group.title[widget.lang] ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          ...group.items.map((subject) {
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xfff4bc43),
                child: Icon(Icons.play_circle_fill, color: Colors.white),
              ),
              title: Text(
                subject["name"][widget.lang] ?? "",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                widget.openPage(
                  (l) => widget.lessonType.toLowerCase() == 'recorded'
                      ? RecordedLessonsScreen(
                          subjectId: subject["_id"], lang: l)
                      : StreamTeachersScreen(
                          subjectId: subject["_id"],
                          lang: l,
                          openPage: widget.openPage,
                        ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class ClassGroup {
  final Map<String, String> title;
  final List<dynamic> items;
  ClassGroup({required this.title, required this.items});
}
