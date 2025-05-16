import 'dart:async';
import 'package:flutter/material.dart';
import 'package:najih_education_app/screens/MyExamsScreen.dart';
import 'package:provider/provider.dart';
import 'package:najih_education_app/services/auth_state.dart';
import 'package:najih_education_app/services/general_service.dart';

class ExamScreen extends StatefulWidget {
  final String lang;
  final String examId;

  const ExamScreen({
    super.key,
    required this.lang,
    required this.examId,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  Map<String, dynamic>? exam;
  List<String?> userAnswers = [];
  List<dynamic> examResult = [];
  int correctAnswersCount = 0;
  List<int> incorrectAnswers = [];
  int remainingTime = 0;
  bool isSubmitted = false;
  bool loading = true; // used both for fetch-time and submit-time
  Timer? timer;

  // ─────────────────────────── lifecycle
  @override
  void initState() {
    super.initState();
    _fetchExam();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ─────────────────────────── helpers
  Future<void> _fetchExam() async {
    final res = await GeneralService().getItem('exams', widget.examId);
    setState(() {
      exam = res;
      loading = false;
      userAnswers = List.filled(res['questions'].length, null);
      remainingTime = (res['time'] as int) * 60; // minutes → seconds
    });
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        timer?.cancel();
        _submit();
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60, s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _getCorrectAnswer(Map<String, dynamic> q) {
    if (q['A'] == true) return 'A';
    if (q['B'] == true) return 'B';
    if (q['C'] == true) return 'C';
    if (q['D'] == true) return 'D';
    return '';
  }

  // ─────────────────────────── main submit
  Future<void> _submit() async {
    if (isSubmitted) return;

    // ── 1. validate answered %
    final answered = userAnswers.where((e) => e != null).length;
    final minReq = (exam!['questions'].length / 2).ceil();
    if (answered < minReq) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.lang == 'ar'
              ? 'يجب الإجابة على $minReq على الأقل'
              : 'You must answer at least $minReq questions'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // ── 2. grade locally
    setState(() {
      isSubmitted = true;
      correctAnswersCount = 0;
      incorrectAnswers.clear();
      examResult.clear();
    });

    for (int i = 0; i < exam!['questions'].length; i++) {
      final q = exam!['questions'][i];
      final correct = _getCorrectAnswer(q);
      final user = userAnswers[i];
      final isCorrect = user == correct;

      if (!isCorrect) incorrectAnswers.add(i);
      if (isCorrect) correctAnswersCount++;

      examResult.add({
        'question': q,
        'userAnswer': user,
        'correctAnswer': correct,
        'isCorrect': isCorrect,
      });
    }

    // ── 3. build payload
    final auth = Provider.of<AuthState>(context, listen: false);
    final body = {
      'examId': exam!['_id'],
      'userId': auth.user?['_id'], // REQUIRED by backend
      'results': examResult,
      'correctAnswersCount': correctAnswersCount,
      'totalQuestions': exam!['questions'].length,
      'submittedAt': DateTime.now().toIso8601String(),
      'examName': exam!['name'],
    };

    try {
      setState(() => loading = true);
      await GeneralService().addItem('examResults', body);

      if (!mounted) return;

      // success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.lang == 'ar'
              ? 'تم إرسال الاختبار بنجاح ✅'
              : 'Exam submitted successfully ✅'),
        ),
      );

      // ─────────── NAVIGATE to “My Exams” ───────────
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyExamsScreen(lang: widget.lang)),
      );
      // If you already have a named route, you can use:
      // Navigator.pushReplacementNamed(context, '/${widget.lang}/my_exams');
      // ───────────────────────────────────────────────
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.lang == 'ar'
              ? 'فشل إرسال الاختبار، حاول لاحقاً'
              : 'Failed to submit exam, try again later'),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ─────────────────────────── UI
  @override
  Widget build(BuildContext context) {
    final isAr = widget.lang == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF143290),
          title: Text(isAr ? 'الاختبار' : 'Exam',
              style: const TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // timer
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${isAr ? 'الوقت المتبقي' : 'Time Remaining'}: '
                        '${_formatTime(remainingTime)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // questions
                    ...List.generate(exam!['questions'].length, (i) {
                      final q = exam!['questions'][i];
                      return _QuestionCard(
                        index: i,
                        question: q,
                        isAr: isAr,
                        isSubmitted: isSubmitted,
                        userAnswer: userAnswers[i],
                        correctGetter: _getCorrectAnswer,
                        onSelect: (opt) => setState(() {
                          if (!isSubmitted) userAnswers[i] = opt;
                        }),
                      );
                    }),

                    // result box
                    if (isSubmitted) ...[
                      const SizedBox(height: 24),
                      _ResultBox(
                        isAr: isAr,
                        totalQuestions: exam!['questions'].length,
                        correctAnswers: correctAnswersCount,
                        incorrectCount: incorrectAnswers.length,
                      ),
                    ],

                    // submit button
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: (isSubmitted || remainingTime <= 0)
                          ? null
                          : () => _submit(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF143290),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        isAr ? 'إرسال الاختبار' : 'Submit Exam',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────── reusable widgets
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.isAr,
    required this.isSubmitted,
    required this.userAnswer,
    required this.correctGetter,
    required this.onSelect,
  });

  final int index;
  final Map<String, dynamic> question;
  final bool isAr;
  final bool isSubmitted;
  final String? userAnswer;
  final String Function(Map<String, dynamic>) correctGetter;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    final correctOpt = correctGetter(question);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isAr ? 'السؤال' : 'Question'} ${index + 1}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF143290),
                ),
              ),
              Text(isAr ? 'اختر إجابة' : 'Choose answer',
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),

          // optional image
          if (question['image'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(question['image']['url']),
              ),
            ),

          // answers grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.0,
            children: ['A', 'B', 'C', 'D'].map((opt) {
              final isSelected = userAnswer == opt;
              final isCorrect = correctOpt == opt;
              final showResult = isSubmitted;

              Color bg = Colors.white;
              Color txt = Colors.black;

              if (showResult) {
                if (isCorrect) {
                  bg = Colors.green;
                  txt = Colors.white;
                } else if (isSelected) {
                  bg = Colors.red;
                  txt = Colors.white;
                }
              } else if (isSelected) {
                bg = const Color(0xFFF4BC43);
                txt = Colors.white;
              }

              return GestureDetector(
                onTap: isSubmitted ? null : () => onSelect(opt),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: 40, maxHeight: 40),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bg,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(opt,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: txt,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox({
    required this.isAr,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectCount,
  });

  final bool isAr;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isAr ? 'النتائج' : 'Results',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF143290),
              )),
          const SizedBox(height: 8),
          Text('${isAr ? 'إجابات صحيحة' : 'Correct Answers'}: '
              '$correctAnswers / $totalQuestions'),
          Text('${isAr ? 'إجابات خاطئة' : 'Incorrect Answers'}: '
              '$incorrectCount'),
        ],
      ),
    );
  }
}
