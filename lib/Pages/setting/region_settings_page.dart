import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegionSettingsPage extends StatefulWidget {
  const RegionSettingsPage({super.key});

  @override
  State<RegionSettingsPage> createState() => _RegionSettingsPageState();
}

class _RegionSettingsPageState extends State<RegionSettingsPage> {
  String _selectedCurrency = 'USD';
  final List<String> _currencies = ['USD', 'EUR', 'JOD', 'SAR', 'EGP'];

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  void _loadCurrency() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final box = await Hive.openBox('${email}_region');
    setState(() {
      _selectedCurrency = box.get('currency', defaultValue: 'USD');
    });
  }

  void _changeCurrency(String? value) async {
    if (value == null) return;
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final box = await Hive.openBox('${email}_region');
    await box.put('currency', value);
    setState(() => _selectedCurrency = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Region Settings"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Preferred Currency", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _currencies.map((cur) => DropdownMenuItem(value: cur, child: Text(cur))).toList(),
              onChanged: _changeCurrency,
            ),
          ],
        ),
      ),
    );
  }
}
