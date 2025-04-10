import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditTransactionPage extends StatefulWidget {
  final Map<String, dynamic> transaction;
  const EditTransactionPage({super.key, required this.transaction});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Food', 'Transport', 'Entertainment', 'Bills', 'Shopping', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountController.text = tx['amount'].toString();
    _noteController.text = tx['note'] ?? '';
    _type = tx['type'];
    _selectedCategory = tx['category'];
    _selectedDate = (tx['date'] as Timestamp).toDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
      appBar: AppBar(
        title: const Text("Edit Transaction"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _circleDecoration(200, const Color(0xFF00B4D8).withOpacity(0.2)),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: _circleDecoration(250, const Color(0xFF0077B6).withOpacity(0.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ToggleButtons(
                      isSelected: [_type == 'income', _type == 'expense'],
                      onPressed: (index) {
                        setState(() {
                          _type = index == 0 ? 'income' : 'expense';
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      selectedColor: Colors.white,
                      fillColor: _type == 'income' ? Colors.green : Colors.red,
                      color: Colors.black,
                      constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
                      children: const [
                        Text("Income"),
                        Text("Expense"),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: "Note (optional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("Date: "),
                        TextButton(
                          onPressed: _pickDate,
                          child: Text("${_selectedDate.toLocal()}".split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077B6),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Save Changes", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    final id = widget.transaction['id'];
    final amount = double.tryParse(_amountController.text.trim());

    if (id == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid input")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('transactions').doc(id).update({
        'type': _type,
        'amount': amount,
        'category': _selectedCategory,
        'note': _noteController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transaction updated!")));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
