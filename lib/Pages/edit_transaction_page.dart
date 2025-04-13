import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final editTransactionControllerProvider = ChangeNotifierProvider.family<
  EditTransactionController,
  Map<String, dynamic>
>((ref, transaction) {
  return EditTransactionController(transaction);
});

class EditTransactionController extends ChangeNotifier {
  final Map<String, dynamic> transaction;

  EditTransactionController(this.transaction) {
    amountController.text = transaction['amount'].toString();
    noteController.text = transaction['note'] ?? '';
    type = transaction['type'];
    selectedCategory = transaction['category'];
    selectedDate = (transaction['date'] as Timestamp).toDate();
  }

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String type = 'expense';
  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  bool isSubmitting = false;

  final List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Shopping',
    'Other',
  ];

  void setType(String newType) {
    type = newType;
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    final id = transaction['id'];
    final amount = double.tryParse(amountController.text.trim());

    if (id == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid input")));
      return;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(id)
          .update({
            'type': type,
            'amount': amount,
            'category': selectedCategory,
            'note': noteController.text.trim(),
            'date': Timestamp.fromDate(selectedDate),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Transaction updated!")));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: \${e.toString()}")));
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}

class EditTransactionPage extends ConsumerWidget {
  final Map<String, dynamic> transaction;
  const EditTransactionPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      editTransactionControllerProvider(transaction),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0077B6),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit_note, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    "Edit Transaction",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _circleDecoration(
              200,
              const Color(0xFF00B4D8).withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: _circleDecoration(
              250,
              const Color(0xFF0077B6).withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ToggleButtons(
                      isSelected: [
                        controller.type == 'income',
                        controller.type == 'expense',
                      ],
                      onPressed:
                          (index) => controller.setType(
                            index == 0 ? 'income' : 'expense',
                          ),
                      borderRadius: BorderRadius.circular(12),
                      selectedColor: Colors.white,
                      fillColor:
                          controller.type == 'income'
                              ? Colors.green
                              : Colors.red,
                      color: Colors.black87,
                      constraints: const BoxConstraints(
                        minWidth: 120,
                        minHeight: 40,
                      ),
                      children: const [Text("Income"), Text("Expense")],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: controller.selectedCategory,
                      items:
                          controller.categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ),
                              )
                              .toList(),
                      onChanged: (val) => controller.setCategory(val!),
                      decoration: InputDecoration(
                        labelText: "Category",
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.noteController,
                      decoration: InputDecoration(
                        labelText: "Note (optional)",
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) controller.setDate(picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF0077B6),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${controller.selectedDate.toLocal()}".split(
                                ' ',
                              )[0],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            controller.isSubmitting
                                ? null
                                : () => controller.submit(context),
                        icon: const Icon(
                          Icons.save_alt_rounded,
                          color: Colors.white,
                        ),
                        label:
                            controller.isSubmitting
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text("Save Changes"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077B6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
