import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:najih_education_app/constants/api_config.dart';
import 'package:najih_education_app/services/auth_state.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String lang;
  const ProfileScreen({super.key, required this.lang});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  bool isLoading = true;
  late String _token;
  Map<String, dynamic>? userData;

  // Controllers
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
    final auth = Provider.of<AuthState>(context, listen: false);
    _token = auth.token!;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}usersRouter/getuser/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (res.statusCode == 200) {
      userData = jsonDecode(res.body);
      final s = userData!['studentDetails'];
      nameController.text = userData!['name'] ?? '';
      fatherNameController.text = s['fatherName'] ?? '';
      lastNameController.text = s['lastName'] ?? '';
      nationalityController.text = s['nationality'] ?? '';
      residenceController.text = s['residence'] ?? '';
      whatsAppController.text = s['whatsApp'] ?? '';
      heardFromController.text = s['heardFrom'] ?? '';
      setState(() => isLoading = false);
    } else {
      debugPrint('Failed to load profile – ${res.statusCode}');
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
    final res = await http.put(
      Uri.parse('${ApiConfig.baseUrl}usersRouter/getuser/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(updatedData),
    );
    if (res.statusCode == 200) {
      setState(() => isEditing = false);
      fetchUserData();
    } else {
      debugPrint('Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          widget.lang == 'en' ? 'Profile' : 'الملف الشخصي',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: isEditing ? Colors.green : Colors.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                if (isEditing) {
                  updateProfile();
                } else {
                  setState(() => isEditing = true);
                }
              },
              icon: Icon(isEditing ? Icons.check : Icons.edit_square),
              label: Text(isEditing
                  ? (widget.lang == 'en' ? 'Save' : 'حفظ')
                  : (widget.lang == 'en' ? 'Edit' : 'تعديل')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // header
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      nameController.text.isEmpty
                          ? 'No Name'
                          : nameController.text,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            _fieldCard('Name', nameController),
            _fieldCard('Father Name', fatherNameController),
            _fieldCard('Last Name', lastNameController),
            _fieldCard('Nationality', nationalityController),
            _fieldCard('Residence', residenceController),
            _fieldCard('WhatsApp', whatsAppController),
            _fieldCard('Heard From', heardFromController),
          ],
        ),
      ),
    );
  }

  // --- UI helper ---
  Widget _fieldCard(String label, TextEditingController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          TextField(
            controller: c,
            readOnly: !isEditing,
            decoration:
                const InputDecoration(isDense: true, border: InputBorder.none),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
