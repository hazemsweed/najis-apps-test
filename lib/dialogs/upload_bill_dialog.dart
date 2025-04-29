import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class UploadBillDialog extends StatefulWidget {
  const UploadBillDialog({super.key});

  @override
  State<UploadBillDialog> createState() => _UploadBillDialogState();
}

class _UploadBillDialogState extends State<UploadBillDialog> {
  File? billFile;

  Future<void> pick() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => billFile = File(res.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload bill'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          billFile == null
              ? const Icon(Icons.receipt_long, size: 64, color: Colors.grey)
              : Image.file(billFile!, height: 120),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: pick,
            icon: const Icon(Icons.upload),
            label: const Text('Choose image'),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: billFile != null
              ? () => Navigator.pop<File>(context, billFile)
              : null,
          child: const Text('OK'),
        )
      ],
    );
  }
}
