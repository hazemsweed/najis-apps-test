import 'package:flutter/material.dart';

class MyLessonsScreen extends StatelessWidget {
  final String lang;

  const MyLessonsScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final lessons = [
      {
        'title': lang == 'en'
            ? 'Math - Algebra Basics'
            : 'الرياضيات - أساسيات الجبر',
        'type': 'Recorded',
        'teacher': 'Mr. Ahmad',
      },
      {
        'title': lang == 'en' ? 'Biology - Cells' : 'الأحياء - الخلايا',
        'type': 'Stream',
        'teacher': 'Ms. Rana',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.video_collection_rounded, size: 36),
              title: Text(lesson['title']!),
              subtitle: Text(
                '${lang == 'en' ? 'Teacher' : 'المعلم'}: ${lesson['teacher']} | '
                '${lang == 'en' ? 'Type' : 'النوع'}: ${lesson['type']}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  // TODO: View lesson
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
