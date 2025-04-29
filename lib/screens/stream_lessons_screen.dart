import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:najih_education_app/services/auth_state.dart';
import 'package:najih_education_app/services/general_service.dart';
import 'package:najih_education_app/dialogs/bill_uploader_dialog.dart';

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
  bool purchaseLoading = false; // ⬅ button spinner
  bool purchaseDone = false; // ⬅ disable after success

  late String _lang = widget.lang;
  Map<String, dynamic>? item; // {subject, teacher, lessons}
  List<String> selected = [];
  bool enrollEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await _gs.getItem(
        't_lessons/getLessonsForWeb',
        "${widget.subjectId}/${widget.teacherId}",
      );
      setState(() {
        item = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => loading = false);
    }
  }

  // ────────── pick bill helper ──────────
  Future<File?> _pickBillDialog() async {
    File? picked;
    await showDialog(
      context: context,
      builder: (_) => _UploadBillDialog(
        onPicked: (f) => picked = f,
        lang: _lang,
      ),
    );
    return picked;
  }

  // ────────── purchase flow ──────────
  Future<void> _purchase() async {
    if (purchaseLoading || purchaseDone) return;

    final auth = AuthState();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    final Map<String, dynamic>? billJson = await showDialog(
      context: context,
      builder: (_) => BillUploaderDialog(lang: _lang),
    );
    if (billJson == null) return; // user cancelled

    if (billJson == null) return; // user cancelled

    setState(() => purchaseLoading = true);

    try {
      final subj = item!['subject'];
      final teacher = item!['teacher'];

      final payload = {
        "source": "teachersLessonsIds",
        "purchasedLessons": {widget.subjectId: selected},
        "subjectId": widget.subjectId,
        "teacherId": widget.teacherId,
        "userId": auth.user!['_id'],
        "status": "in progress",
        "teachersLessonsIds": selected,
        "teachersLessons": _fullSelectedLessons(),
        "userName": auth.user!['name'],
        "userEmail": auth.user!['username'],
        "price": 0,
        "lessonsPrice": subj['lessonPrice'],
        "subjectName": subj['name']['ar'],
        "subjectClass": "${subj['level']['ar']} ${subj['class']}",
        "bill": billJson,
      };

      await _gs.addItem('studentsLessons', payload);

      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => const _SuccessDialog(),
        );
        setState(() {
          purchaseDone = true;
          enrollEnabled = true;
          selected.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_lang == 'en' ? 'Upload failed' : 'فشل الرفع')),
        );
      }
    } finally {
      if (mounted) setState(() => purchaseLoading = false);
    }
  }

  // map of lessons objects for backend
  List<dynamic> _fullSelectedLessons() {
    final lessons = item!['lessons'] as List<dynamic>;
    return lessons.where((e) => selected.contains(e['_id'])).toList();
  }

// toggle selection on/off for a lesson id
  void toggle(String id) {
    setState(() {
      selected.contains(id) ? selected.remove(id) : selected.add(id);
    });
  }

  // ────────── UI ──────────
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
                              onPressed: () =>
                                  setState(() => enrollEnabled = false),
                              child: Text(
                                  _lang == 'en' ? 'Enroll now' : 'سجل الآن'),
                            )
                          : ElevatedButton(
                              onPressed: selected.isNotEmpty ? _purchase : null,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff588157)),
                              child: purchaseLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(_lang == 'en'
                                      ? (purchaseDone
                                          ? 'Done'
                                          : 'Purchase selected')
                                      : (purchaseDone
                                          ? 'تم الإرسال'
                                          : 'اشتر الدروس')),
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
                      if (!enrollEnabled && !purchaseDone) toggle(l['_id']);
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Dialog widgets
//////////////////////////////////////////////////////////////////////////////
class _UploadBillDialog extends StatefulWidget {
  final void Function(File) onPicked;
  final String lang;
  const _UploadBillDialog({required this.onPicked, required this.lang});

  @override
  State<_UploadBillDialog> createState() => _UploadBillDialogState();
}

class _UploadBillDialogState extends State<_UploadBillDialog> {
  File? bill;

  Future<void> _pick() async {
    final res = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    if (res != null && res.files.isNotEmpty) {
      setState(() => bill = File(res.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.lang == 'en' ? 'Upload bill' : 'ارفع الفاتورة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          bill == null
              ? const Icon(Icons.receipt_long, size: 64, color: Colors.grey)
              : Image.file(bill!, height: 120),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.upload),
            label: Text(widget.lang == 'en' ? 'Choose image' : 'اختَر صورة'),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.lang == 'en' ? 'Cancel' : 'إلغاء')),
        ElevatedButton(
          onPressed: bill != null
              ? () {
                  widget.onPicked(bill!);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Success 🎉'),
      content: const Text('Your purchase request was sent successfully.'),
      actions: [
        ElevatedButton(
            onPressed: () => Navigator.pop(context), child: const Text('OK'))
      ],
    );
  }
}
