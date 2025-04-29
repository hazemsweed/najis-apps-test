import 'package:flutter/material.dart';
import 'package:najih_education_app/services/general_service.dart';

class StreamLessonsScreen extends StatefulWidget {
  final String subjectId;
  final String teacherId;
  final String lang;

  const StreamLessonsScreen({
    super.key,
    required this.subjectId,
    required this.teacherId,
    required this.lang,
  });

  @override
  State<StreamLessonsScreen> createState() => _StreamLessonsScreenState();
}

class _StreamLessonsScreenState extends State<StreamLessonsScreen> {
  final GeneralService _gs = GeneralService();
  bool loading = true;

  late String _lang = widget.lang;
  Map<String, dynamic>? item; // {subject, teacher, lessons}

  bool enrollEnabled = true;
  List<String> selected = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      final data = await _gs.getItem('t_lessons/getLessonsForWeb',
          "${widget.subjectId}/${widget.teacherId}");
      setState(() {
        item = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching stream lessons: $e');
      setState(() => loading = false);
    }
  }

  // ───── helpers ─────
  void toggle(String id) => setState(
      () => selected.contains(id) ? selected.remove(id) : selected.add(id));

  void enroll() => setState(() => enrollEnabled = false);

  void purchase() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          _lang == 'en' ? 'Pretend purchase complete!' : 'تم الشراء (وهمي)!')));

  // ───── UI ─────
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xff143290))));
    }
    if (item == null) {
      return Scaffold(
          body: Center(
              child: Text(_lang == 'en' ? 'Error' : 'حدث خطأ في التحميل')));
    }

    final lessons = item!['lessons'] as List<dynamic>;
    final subj = item!['subject'];
    final teacher = item!['teacher'];

    return Scaffold(
      body: Directionality(
        textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // header
              Text(subj['name'][_lang] ?? '',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff143290))),
              const SizedBox(height: 4),
              Text("${subj['level'][_lang]}  ${subj['class']}",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff4bc43))),
              const SizedBox(height: 24),

              // teacher card
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xfff4bc43),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(teacher['name']),
                  subtitle: Text(
                      "${_lang == 'en' ? 'Age' : 'العمر'}: ${teacher['age']}  "
                      "${_lang == 'en' ? 'Exp' : 'خبرة'}: ${teacher['experience']}"),
                ),
              ),
              const SizedBox(height: 24),

              // price & buttons
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          "${_lang == 'en' ? 'Price per lesson' : 'سعر الدرس'}: "
                          "${subj['lessonPrice']} EGP",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      enrollEnabled
                          ? ElevatedButton(
                              onPressed: enroll,
                              child: Text(
                                  _lang == 'en' ? 'Enroll now' : 'سجل الآن'),
                            )
                          : ElevatedButton(
                              onPressed: selected.isNotEmpty ? purchase : null,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff588157)),
                              child: Text(_lang == 'en'
                                  ? 'Purchase selected'
                                  : 'اشتر الدروس'),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // lessons list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lessons.length,
                itemBuilder: (_, idx) {
                  final l = lessons[idx];
                  final sel = selected.contains(l['_id']);
                  return GestureDetector(
                    onTap: () {
                      if (!enrollEnabled) toggle(l['_id']);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            sel ? Colors.green.shade200 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(l['name'][_lang] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              Text("${l['startDate']} – ${l['endDate']}",
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(l['description'][_lang] ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
