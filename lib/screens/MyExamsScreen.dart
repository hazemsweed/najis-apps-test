import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:najih_education_app/services/general_service.dart';

class MyExamsScreen extends StatefulWidget {
  final String lang; // 'en' or 'ar'
  const MyExamsScreen({super.key, required this.lang});

  @override
  _MyExamsScreenState createState() => _MyExamsScreenState();
}

class _MyExamsScreenState extends State<MyExamsScreen> {
  bool loading = true;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    try {
      final res =
          await GeneralService().getItems('examResults/getUserExams/byUserId');
      setState(() {
        items = res;
      });
    } catch (e) {
      // Optional: handle error
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.lang == 'ar';

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF143290),
          title: Text(
            isAr ? 'امتحاناتي' : 'My Exams',
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    int cols = 1;
                    if (constraints.maxWidth >= 1024) {
                      cols = 3;
                    } else if (constraints.maxWidth >= 600) {
                      cols = 2;
                    }

                    // ⏬ Dynamically calculate the correct childAspectRatio
                    final double cardWidth =
                        (constraints.maxWidth - (cols - 1) * 16) / cols;
                    const double estimatedCardHeight = 140;
                    final double aspectRatio = cardWidth / estimatedCardHeight;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) {
                        final item = items[i];
                        final examName =
                            item['examName'][widget.lang] as String;
                        final correct = item['correctAnswersCount'] as int;
                        final total = item['totalQuestions'] as int;
                        final percent =
                            (correct * 100 / total).toStringAsFixed(0);
                        final submittedAt =
                            DateTime.parse(item['submittedAt'] as String);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(
                              top: BorderSide(
                                color: Color(0xFFF4BC43),
                                width: 4,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                examName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF143290),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${isAr ? 'النتيجة' : 'Result'}: $percent %',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                '${isAr ? 'الإجابات الصحيحة' : 'Correct Answers'}: $correct / $total',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                '${isAr ? 'تاريخ التقديم' : 'Submitted At'}: ${DateFormat.yMd().add_jm().format(submittedAt)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}
