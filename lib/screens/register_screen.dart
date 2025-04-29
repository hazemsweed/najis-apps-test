import 'package:flutter/material.dart';
import 'package:najih_education_app/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Student-specific
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _schoolTypeController = TextEditingController();
  final TextEditingController _residenceController = TextEditingController();
  final TextEditingController _whatsAppController = TextEditingController();
  final TextEditingController _heardFromController = TextEditingController();

  // Teacher-specific
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  bool _workedOnZoom = false;

  String _role = 'student';
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final Map<String, dynamic> base = {
        "email": _emailController.text.trim(),
        "username": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "name": _nameController.text.trim(),
        "role": _role,
      };

      if (_role == 'student') {
        base.addAll({
          "fatherName": _fatherNameController.text.trim(),
          "lastName": _lastNameController.text.trim(),
          "gender": _genderController.text.trim(),
          "nationality": _nationalityController.text.trim(),
          "birthYear": int.tryParse(_birthYearController.text.trim()) ?? 2000,
          "schoolType": _schoolTypeController.text.trim(),
          "residence": _residenceController.text.trim(),
          "whatsApp": _whatsAppController.text.trim(),
          "heardFrom": _heardFromController.text.trim(),
        });
      } else if (_role == 'teacher') {
        base.addAll({
          "age": int.tryParse(_ageController.text.trim()) ?? 25,
          "levels": [
            {"en": "Preparatory", "ar": "اعدادي"},
            {"en": "High School", "ar": "ثانوية عامة"},
            {"en": "Primary", "ar": "ابتدائي"}
          ],
          "schoolName": _schoolNameController.text.trim(),
          "phoneNumber": _phoneNumberController.text.trim(),
          "experience": int.tryParse(_experienceController.text.trim()) ?? 5,
          "address": _addressController.text.trim(),
          "subjects": _subjectsController.text.trim(),
          "workedOnZoom": _workedOnZoom,
          "image": {"url": "none", "filename": "none"},
          "cv": {"url": "none", "filename": "none"},
        });
      }

      final result = await AuthService().register(base);
      setState(() => _isLoading = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${result['message']}")),
        );
      }
    }
  }

  Widget _buildStudentFields() {
    return Column(
      children: [
        _buildTextField(_fatherNameController, "Father Name"),
        _buildTextField(_lastNameController, "Last Name"),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            value: _genderController.text.isNotEmpty
                ? _genderController.text
                : null,
            items: const [
              DropdownMenuItem(value: 'male', child: Text("Male")),
              DropdownMenuItem(value: 'female', child: Text("Female")),
            ],
            onChanged: (value) {
              _genderController.text = value!;
            },
            decoration: const InputDecoration(
                labelText: "Gender", border: OutlineInputBorder()),
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
          ),
        ),
        _buildTextField(_nationalityController, "Nationality"),
        _buildTextField(_birthYearController, "Birth Year",
            inputType: TextInputType.number),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            value: _schoolTypeController.text.isNotEmpty
                ? _schoolTypeController.text
                : null,
            items: const [
              DropdownMenuItem(value: 'public', child: Text("Public")),
              DropdownMenuItem(value: 'languages', child: Text("Languages")),
            ],
            onChanged: (value) {
              _schoolTypeController.text = value!;
            },
            decoration: const InputDecoration(
                labelText: "School Type", border: OutlineInputBorder()),
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
          ),
        ),
        _buildTextField(_residenceController, "Residence"),
        _buildTextField(_whatsAppController, "WhatsApp"),
        _buildTextField(_heardFromController, "Heard From"),
      ],
    );
  }

  Widget _buildTeacherFields() {
    return Column(
      children: [
        _buildTextField(_ageController, "Age", inputType: TextInputType.number),
        _buildTextField(_schoolNameController, "School Name"),
        _buildTextField(_phoneNumberController, "Phone Number"),
        _buildTextField(_experienceController, "Experience (years)",
            inputType: TextInputType.number),
        _buildTextField(_addressController, "Address"),
        _buildTextField(_subjectsController, "Subjects (comma-separated)"),
        SwitchListTile(
          value: _workedOnZoom,
          onChanged: (value) => setState(() => _workedOnZoom = value),
          title: const Text("Worked on Zoom"),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, "Name"),
              _buildTextField(_emailController, "Email"),
              _buildTextField(_passwordController, "Password"),
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text("Student")),
                  DropdownMenuItem(value: 'teacher', child: Text("Teacher")),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _role = value);
                },
                decoration: const InputDecoration(labelText: "Role"),
              ),
              const SizedBox(height: 20),
              if (_role == 'student') _buildStudentFields(),
              if (_role == 'teacher') _buildTeacherFields(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Register"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
