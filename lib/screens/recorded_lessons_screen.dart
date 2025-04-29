import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:najih_education_app/services/auth_state.dart';
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
  final GeneralService _gs = GeneralService();

  bool loading = true;
  Map<String, dynamic>? item; // subject document
  List<String> selected = []; // lessons selected for purchase
  bool enrollEnabled = true; // step-1 vs step-2
  late String _lang = widget.lang;

  File? billFile;

  @override
  void initState() {
    super.initState();
    fetchItem();
  }

  // ───────────────── data ─────────────────
  Future<void> fetchItem() async {
    try {
      final data =
          await _gs.getItem('r_subjects/getByFilter', widget.subjectId);
      setState(() {
        item = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching item: $e');
      setState(() => loading = false);
    }
  }

  // ───────────────── helpers ─────────────────
  void toggle(String id) => setState(
      () => selected.contains(id) ? selected.remove(id) : selected.add(id));

  void enroll() => setState(() => enrollEnabled = false);

  // pick file
  Future<File?> _pickBill() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      return File(res.files.single.path!);
    }
    return null;
  }

  // purchase flow
  Future<void> purchaseFlow() async {
    final auth = AuthState();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    billFile = await _pickBill();
    if (billFile == null) return;

    final formData = {
      "source": "recordedLessonsIds",
      "purchasedLessons": {widget.subjectId: selected},
      "subjectId": widget.subjectId,
      "userId": auth.user!['_id'],
      "status": "in progress",
      "recordedLessonsIds": selected,
      "userName": auth.user!['name'],
      "userEmail": auth.user!['username'],
      "price": 0,
      "lessonsPrice": item!['lessonPrice'],
      "subjectName": item!['name']['ar'],
      "subjectClass": "${item!['level']['ar']} ${item!['class']}",
      "bill": base64Encode(await billFile!.readAsBytes()),
    };

    await _gs.addItem('studentsLessons', formData);

    if (mounted) {
      await showDialog(
        context: context,
        builder: (_) => const _SuccessDialog(),
      );
      setState(() {
        enrollEnabled = true;
        selected.clear();
        billFile = null;
      });
    }
  }

  // ───────────────── UI ─────────────────
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

    return Scaffold(
      body: Directionality(
        textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // header
              Text(
                "${item!['name'][_lang]} - ${item!['level'][_lang]} ${item!['class']}",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff143290)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              _buildInfoCard(),
              const SizedBox(height: 24),

              // enrol / purchase button
              enrollEnabled
                  ? ElevatedButton(
                      onPressed: enroll,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff143290)),
                      child: Text(_lang == 'en' ? "Enroll Now" : "سجل الآن"),
                    )
                  : ElevatedButton(
                      onPressed: selected.isNotEmpty ? purchaseFlow : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff588157)),
                      child: Text(_lang == 'en'
                          ? "Purchase Selected Lessons"
                          : "شراء الدروس المختارة"),
                    ),
              const SizedBox(height: 24),

              if (item!['lessonsIds'] != null) _buildLessonsList(),
            ],
          ),
        ),
      ),
    );
  }

  // build info card (unchanged)
  Widget _buildInfoCard() {
    /* … keep existing implementation … */ return Container();
  }

  // lessons list
  Widget _buildLessonsList() {
    final lessons = item!['lessonsIds'] as List<dynamic>;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, idx) {
        final l = lessons[idx];
        final sel = selected.contains(l['_id']);
        return GestureDetector(
          onTap: () => !enrollEnabled ? toggle(l['_id']) : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sel ? Colors.green.shade200 : Colors.grey.shade100,
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
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Text("${l['startDate']} - ${l['endDate']}",
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
    );
  }
}

// simple success dialog
class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Success 🎉'),
      content: const Text('Your purchase request was sent successfully.'),
      actions: [
        ElevatedButton(
            onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ],
    );
  }
}
