import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/recorded_lessons_screen.dart';
import 'package:najih_education_app/services/general_service.dart';

typedef PageBuilder = Widget Function(String lang);

class MiddleSchoolScreen extends StatefulWidget {
  final String lang;
  final String lessonType;
  final Function(PageBuilder) openPage;

  const MiddleSchoolScreen({
    super.key,
    required this.lang,
    required this.lessonType,
    required this.openPage,
  });

  @override
  State<MiddleSchoolScreen> createState() => _MiddleSchoolScreenState();
}

class _MiddleSchoolScreenState extends State<MiddleSchoolScreen> {
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
          .getItemsWithQuery(collection, {"type": "Preparatory"});

      populateClasses();
    } catch (e) {
      debugPrint('Error fetching middle school data: $e');
      setState(() => loading = false);
    }
  }

  void populateClasses() {
    classes = [
      ClassGroup(
        title: {"en": "First Preparatory", "ar": "الصف الأول الإعدادي"},
        items: items.where((item) => item["class"] == 1).toList(),
      ),
      ClassGroup(
        title: {"en": "Second Preparatory", "ar": "الصف الثاني الإعدادي"},
        items: items.where((item) => item["class"] == 2).toList(),
      ),
      ClassGroup(
        title: {"en": "Third Preparatory", "ar": "الصف الثالث الإعدادي"},
        items: items.where((item) => item["class"] == 3).toList(),
      ),
    ];
    setState(() => loading = false);
  }

  String getPageType() {
    return widget.lessonType.toLowerCase() == "recorded"
        ? (widget.lang == 'en' ? "Recorded" : "مسجلة")
        : (widget.lang == 'en' ? "Stream" : "مباشرة");
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
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    // header
                    Center(
                      child: Column(
                        children: [
                          Text(
                            widget.lang == 'en'
                                ? "Middle School"
                                : "المدرسة الإعدادية",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff143290)),
                          ),
                          const SizedBox(height: 6),
                          Text(getPageType(),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xfff4bc43))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // content
                    ...classes.map(_buildClassCard),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildClassCard(ClassGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xff143290), Color(0xfff4bc43)]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Center(
              child: Text(group.title[widget.lang] ?? "",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          ...group.items.map((subject) => ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xfff4bc43),
                  child: Icon(Icons.play_circle_fill, color: Colors.white),
                ),
                title: Text(subject["name"][widget.lang] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => widget.openPage(
                  (l) =>
                      RecordedLessonsScreen(subjectId: subject["_id"], lang: l),
                ),
              )),
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
