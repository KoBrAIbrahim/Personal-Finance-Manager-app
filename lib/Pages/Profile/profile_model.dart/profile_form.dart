import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_profile_field.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _phoneController = TextEditingController();
  String _gender = 'Prefer not to say';
  DateTime? _birthday;
  bool _isPublic = true;
  bool _isLoading = true;

  final List<String> _genders = ['Male', 'Female', 'Prefer not to say'];
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final email = user?.email;
    if (email == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(email).get();
    final data = doc.data();

    setState(() {
      _phoneController.text = data?['phone'] ?? '';
      _gender = data?['gender'] ?? 'Prefer not to say';
      _isPublic = data?['isPublic'] ?? true;
      final birthday = data?['birthday'];
      if (birthday != null && birthday is Timestamp) {
        _birthday = birthday.toDate();
      }
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    final email = user?.email;
    if (email == null) return;

    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'phone': _phoneController.text.trim(),
      'gender': _gender,
      'birthday': _birthday != null ? Timestamp.fromDate(_birthday!) : null,
      'isPublic': _isPublic,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile updated!")));
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (theme.brightness == Brightness.light)
            const BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Your Profile Info",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: user?.email ?? '',
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _gender,
            items:
                _genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
            onChanged: (val) => setState(() => _gender = val!),
            decoration: const InputDecoration(
              labelText: "Gender",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          CustomProfileField(
            controller: _phoneController,
            label: "Phone Number",
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text("Birthday:", style: theme.textTheme.bodyMedium),
              const SizedBox(width: 10),
              TextButton(
                onPressed: _pickBirthday,
                child: Text(
                  _birthday != null
                      ? "${_birthday!.toLocal()}".split(' ')[0]
                      : "Select date",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text("Make account public"),
            value: _isPublic,
            onChanged: (val) => setState(() => _isPublic = val),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
