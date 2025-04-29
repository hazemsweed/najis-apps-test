import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:najih_education_app/services/file_upload_service.dart';

/// Pops up a circle thumbnail ► pick ► upload with progress, then
/// returns the server JSON ({ url, filename, … }) via Navigator.pop.
class BillUploaderDialog extends StatefulWidget {
  const BillUploaderDialog({
    super.key,
    required this.lang, // 'en' | 'ar'
    this.filter = 'only-images', // or 'all-files'
    this.route = 'studentsLessons', // backend route segment
  });

  final String lang;
  final String filter;
  final String route;

  @override
  State<BillUploaderDialog> createState() => _BillUploaderDialogState();
}

class _BillUploaderDialogState extends State<BillUploaderDialog> {
  File? _file;
  int _progress = 0; // 0‒100
  bool _uploading = false;

  // ───────────────────────── pick ─────────────────────────
  Future<void> _chooseFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _file = File(result.files.single.path!);
        _progress = 0;
      });
    }
  }

  // ───────────────────────── upload ─────────────────────────
  Future<void> _startUpload() async {
    if (_file == null) return;
    setState(() => _uploading = true);

    final uploader = FileUploadService(); // uses default baseUrl
    try {
      final json = await uploader.uploadFile(
        file: _file!,
        route: widget.route,
        filter: widget.filter,
        onProgress: (sent, total) =>
            setState(() => _progress = (sent / total * 100).round()),
      );
      if (mounted) Navigator.pop(context, json); // success → return
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(widget.lang == 'en' ? 'Upload failed' : 'فشل رفع الفاتورة'),
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ───────────────────────── UI ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final isEn = widget.lang == 'en';

    return AlertDialog(
      title: Text(isEn ? 'Upload bill' : 'تحميل الفاتورة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // tap-to-pick avatar
          GestureDetector(
            onTap: _uploading ? null : _chooseFile,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 3),
              ),
              child: _file == null
                  ? Image.asset('assets/home/invoice.png')
                  : ClipOval(child: Image.file(_file!, fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 12),
          _uploading
              ? LinearProgressIndicator(value: _progress / 100)
              : TextButton.icon(
                  onPressed: _chooseFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(isEn ? 'Choose image' : 'اختَر صورة'),
                ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _uploading ? null : () => Navigator.pop(context),
          child: Text(isEn ? 'Cancel' : 'إلغاء'),
        ),
        ElevatedButton(
          onPressed: _file != null && !_uploading ? _startUpload : null,
          child: _uploading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(isEn ? 'Send' : 'إرسال'),
        ),
      ],
    );
  }
}
