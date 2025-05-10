import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:najih_education_app/services/auth_state.dart';
import 'package:najih_education_app/services/general_service.dart';
import 'package:najih_education_app/dialogs/bill_uploader_dialog.dart';
import 'package:provider/provider.dart';

typedef PageBuilder = Widget Function(String lang);

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

  //late String widget.lang = widget.lang;
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

  // ────────── purchase flow ──────────
  Future<void> _purchase() async {
    if (purchaseLoading || purchaseDone) return;

    final auth = Provider.of<AuthState>(context, listen: false);
    final user = auth.user;

    if (user == null || !auth.isLoggedIn || auth.isTokenExpired) {
      if (mounted) {
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    final Map<String, dynamic>? billJson = await showDialog(
      context: context,
      builder: (_) => BillUploaderDialog(lang: widget.lang),
    );
    if (billJson == null) return;

    setState(() => purchaseLoading = true);

    try {
      final subj = item!['subject'];

      final payload = {
        "source": "teachersLessonsIds",
        "purchasedLessons": {widget.subjectId: selected},
        "subjectId": widget.subjectId,
        "teacherId": widget.teacherId,
        "userId": user['_id'],
        "status": "in progress",
        "teachersLessonsIds": selected,
        "teachersLessons": _fullSelectedLessons(),
        "userName": user['name'],
        "userEmail": user['username'],
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
      debugPrint('AddItem error: $e'); // 👈 add this
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(widget.lang == 'en' ? 'Upload failed' : 'فشل الرفع')),
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
        body: Center(
            child: Text(widget.lang == 'en' ? 'Error' : 'حدث خطأ في التحميل')),
      );
    }

    final lessons = item!['lessons'] as List<dynamic>;
    final subj = item!['subject'];
    final teacher = item!['teacher'];

    return Scaffold(
      body: Directionality(
        textDirection:
            widget.lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Column(
            children: [
              // header
              Text(subj['name'][widget.lang] ?? '',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff143290))),
              const SizedBox(height: 4),
              Text("${subj['level'][widget.lang]}  ${subj['class']}",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff4bc43))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xff143290), Color(0xfff4bc43)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          color: Color(0xff143290), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.cake,
                                  size: 16, color: Colors.white70),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.lang == 'en' ? 'Age' : 'العمر'}: ${teacher['age']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.school,
                                  size: 16, color: Colors.white70),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.lang == 'en' ? 'Exp' : 'خبرة'}: ${teacher['experience']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xfff4bc43), Color(0xff143290)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lang == 'en' ? 'Subject Details' : 'تفاصيل المادة',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _iconRow(
                        Icons.date_range,
                        widget.lang == 'en' ? 'Start Date' : 'تاريخ البدء',
                        subj['startDate']),
                    _iconRow(
                        Icons.event,
                        widget.lang == 'en' ? 'End Date' : 'تاريخ الانتهاء',
                        subj['endDate']),
                    _iconRow(
                        Icons.menu_book,
                        widget.lang == 'en' ? 'Lesson Count' : 'عدد الدروس',
                        subj['lessonCount'].toString()),
                    _iconRow(
                      Icons.monetization_on_outlined,
                      widget.lang == 'en' ? 'Price per lesson' : 'سعر الدرس',
                      '${subj['lessonPrice']} ${widget.lang == 'en' ? 'EGP' : 'جنيه'}',
                    ),
                    _iconRow(
                        Icons.event_seat,
                        widget.lang == 'en'
                            ? 'Available Seats'
                            : 'المقاعد المتاحة',
                        subj['availableSeats'].toString()),
                    _iconRow(
                        Icons.chair_alt,
                        widget.lang == 'en'
                            ? 'Remaining Seats'
                            : 'المقاعد المتبقية',
                        subj['remainingSeats'].toString()),
                    _iconRow(
                        Icons.payment,
                        widget.lang == 'en' ? 'Payment Method' : 'طريقة الدفع',
                        subj['paymentMethod']),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // teacher card

              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: enrollEnabled
                    ? ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.white),
                        onPressed: () => setState(() => enrollEnabled = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff143290),
                          foregroundColor:
                              Colors.white, // 👈 makes text/icon white
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        label: Text(
                          widget.lang == 'en' ? 'Enroll Now' : 'سجل الآن',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart_checkout,
                            color: Colors.white),
                        onPressed: selected.isNotEmpty ? _purchase : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff588157),
                          foregroundColor:
                              Colors.white, // 👈 makes text/icon white
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                        label: purchaseLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.lang == 'en'
                                    ? (purchaseDone
                                        ? 'Done'
                                        : 'Purchase Selected')
                                    : (purchaseDone
                                        ? 'تم الإرسال'
                                        : 'اشتر الدروس'),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: sel
                              ? Colors.green.shade100
                              : const Color(0xffF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: sel
                                ? const Color(0xff588157)
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lesson Title
                            Text(
                              l['name'][widget.lang] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff143290),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Date Range
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${l['startDate']} – ${l['endDate']}',
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow
                                        .ellipsis, // prevents overflow
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Description
                            Text(
                              l['description'][widget.lang] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$title: $value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ],
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
