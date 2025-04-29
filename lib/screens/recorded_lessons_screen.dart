import 'package:flutter/material.dart';
import 'package:najih_education_app/services/general_service.dart';

class RecordedLessonsScreen extends StatefulWidget {
  final String subjectId;
  final String lang;

  const RecordedLessonsScreen({
    super.key,
    required this.subjectId,
    required this.lang,
  });

  @override
  State<RecordedLessonsScreen> createState() => _RecordedLessonsScreenState();
}

class _RecordedLessonsScreenState extends State<RecordedLessonsScreen> {
  final GeneralService _generalService = GeneralService();

  Map<String, dynamic>? item;
  List<String> selectedLessons = [];

  bool enrollEnabled = true;
  bool loading = true;
  late String _lang = widget.lang;

  @override
  void didUpdateWidget(covariant RecordedLessonsScreen old) {
    super.didUpdateWidget(old);
    if (old.lang != widget.lang) setState(() => _lang = widget.lang);
  }

  @override
  void initState() {
    super.initState();
    fetchItem();
  }

  Future<void> fetchItem() async {
    try {
      final data = await _generalService.getItem(
          'r_subjects/getByFilter', widget.subjectId);
      setState(() {
        item = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching item: $e');
      setState(() => loading = false);
    }
  }

  // ───── helpers ─────
  void toggleLessonSelection(String id) => setState(() {
        selectedLessons.contains(id)
            ? selectedLessons.remove(id)
            : selectedLessons.add(id);
      });

  void enrollNow() => setState(() => enrollEnabled = false);

  void uploadBillAndPurchase() {
    if (selectedLessons.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_lang == 'en'
            ? 'Upload Bill and Purchase...'
            : 'ارفع الفاتورة وقم بالشراء...'),
      ),
    );
  }

  // ───── UI ─────
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
        body: Center(
            child: Text(_lang == 'en'
                ? 'Error loading data'
                : 'خطأ في تحميل البيانات')),
      );
    }

    return Scaffold(
      body: Directionality(
        textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // title
              Text(
                "${item!['name'][_lang]} - ${item!['level'][_lang]} ${item!['class']}",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff143290)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // info card
              _buildInfoCard(),
              const SizedBox(height: 24),

              // enroll / purchase
              enrollEnabled
                  ? ElevatedButton(
                      onPressed: enrollNow,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff143290)),
                      child: Text(_lang == 'en' ? "Enroll Now" : "سجل الآن"),
                    )
                  : ElevatedButton(
                      onPressed: selectedLessons.isNotEmpty
                          ? uploadBillAndPurchase
                          : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff588157)),
                      child: Text(_lang == 'en'
                          ? "Purchase Selected Lessons"
                          : "شراء الدروس المختارة"),
                    ),
              const SizedBox(height: 24),

              // lessons list
              if (item!['lessonsIds'] != null) _buildLessonsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFfef9c3), Color(0xFFdbeafe)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(_lang == 'en' ? "Price per Lesson:" : "سعر الدرس:",
              "${item!['lessonPrice']} EGP"),
          const SizedBox(height: 6),
          _infoRow(_lang == 'en' ? "Total Price:" : "السعر الكلي:",
              "${item!['lessonPriceAll']} EGP"),
          const SizedBox(height: 12),
          Text(_lang == 'en' ? "Course Dates" : "مواعيد الدورة",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          _infoRow(_lang == 'en' ? "Start Date:" : "تاريخ البدء:",
              item!['startDate'] ?? ''),
          _infoRow(_lang == 'en' ? "End Date:" : "تاريخ الانتهاء:",
              item!['endDate'] ?? ''),
          _infoRow(_lang == 'en' ? "Lesson Count:" : "عدد الدروس:",
              item!['lessonCount'].toString()),
          const SizedBox(height: 12),
          Text(_lang == 'en' ? "Payment Method:" : "طريقة الدفع:",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(item!['paymentMethod'] ?? ''),
          const SizedBox(height: 12),
          Text(
              _lang == 'en'
                  ? "Vodafone Cash / InstaPay Wallet:"
                  : "فودافون كاش / انستاباي:",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const Text("01002126025\nadgahmed@instapay"),
          const SizedBox(height: 8),
          Text(_lang == 'en' ? "For Inquiry:" : "للاستفسار:",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const Text("01503400063\n01011002421"),
        ],
      ),
    );
  }

  Widget _buildLessonsList() {
    final lessons = item!['lessonsIds'] as List<dynamic>;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, idx) {
        final lesson = lessons[idx];
        final selected = selectedLessons.contains(lesson['_id']);
        return GestureDetector(
          onTap: () =>
              !enrollEnabled ? toggleLessonSelection(lesson['_id']) : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? Colors.green.shade200 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 5,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(lesson['name'][_lang] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Text("${lesson['startDate']} - ${lesson['endDate']}",
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(lesson['description'][_lang] ?? '',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {/* TODO: open tutorial */},
                      child: Text(
                          _lang == 'en' ? "View Tutorial" : "عرض فيديو الشرح",
                          style: const TextStyle(color: Colors.blue)),
                    ),
                    const SizedBox(width: 10),
                    if (!enrollEnabled)
                      TextButton(
                        onPressed: () {/* TODO: open lesson */},
                        child: Text(_lang == 'en' ? "View Lesson" : "عرض الدرس",
                            style: const TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            Flexible(child: Text(value)),
          ],
        ),
      );
}
