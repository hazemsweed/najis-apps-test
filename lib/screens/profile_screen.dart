import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String lang;
  const ProfileScreen({super.key, required this.lang});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  bool isLoading = true;
  Map<String, dynamic>? userData;

  // Controllers for editable fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController residenceController = TextEditingController();
  final TextEditingController whatsAppController = TextEditingController();
  final TextEditingController heardFromController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final response = await http.get(
      Uri.parse('http://localhost:1022/usersRouter/getuser/profile'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      userData = jsonDecode(response.body);
      final student = userData!['studentDetails'];

      nameController.text = userData!['name'] ?? '';
      fatherNameController.text = student['fatherName'] ?? '';
      lastNameController.text = student['lastName'] ?? '';
      nationalityController.text = student['nationality'] ?? '';
      residenceController.text = student['residence'] ?? '';
      whatsAppController.text = student['whatsApp'] ?? '';
      heardFromController.text = student['heardFrom'] ?? '';

      setState(() => isLoading = false);
    } else {
      // Handle error
      print('Failed to load profile');
    }
  }

  Future<void> updateProfile() async {
    final updatedData = {
      'name': nameController.text,
      'studentDetails': {
        'fatherName': fatherNameController.text,
        'lastName': lastNameController.text,
        'nationality': nationalityController.text,
        'residence': residenceController.text,
        'whatsApp': whatsAppController.text,
        'heardFrom': heardFromController.text,
      }
    };

    final response = await http.put(
      Uri.parse('http://localhost:1022/usersRouter/getuser/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      setState(() => isEditing = false);
      fetchUserData(); // Refresh data
    } else {
      // Handle error
      print('Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lang == 'en' ? 'Profile' : 'الملف الشخصي'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                updateProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildField('Name', nameController),
            _buildField('Father Name', fatherNameController),
            _buildField('Last Name', lastNameController),
            _buildField('Nationality', nationalityController),
            _buildField('Residence', residenceController),
            _buildField('WhatsApp', whatsAppController),
            _buildField('Heard From', heardFromController),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: !isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
