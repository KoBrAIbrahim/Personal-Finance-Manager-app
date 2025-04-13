import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

    final doc = await FirebaseFirestore.instance.collection('users').doc(email).get();
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

    await FirebaseFirestore.instance
  .collection('users')
  .doc(email)
  .set({
    'phone': _phoneController.text.trim(),
    'gender': _gender,
    'birthday': _birthday != null ? Timestamp.fromDate(_birthday!) : null,
    'isPublic': _isPublic,
  }, SetOptions(merge: true));


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated!")),
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned(
                  top: -80,
                  left: -80,
                  child: _circleDecoration(200, const Color(0xFF00B4D8).withOpacity(0.2)),
                ),
                Positioned(
                  bottom: -100,
                  right: -100,
                  child: _circleDecoration(250, const Color(0xFF0077B6).withOpacity(0.2)),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Your Profile Info",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) => setState(() => _gender = val!),
                          decoration: const InputDecoration(
                            labelText: "Gender",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Phone Number",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            const Text("Birthday: "),
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
                              backgroundColor: const Color(0xFF0077B6),
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
                  ),
                ),
              ],
            ),
    );
  }

  Widget _circleDecoration(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
