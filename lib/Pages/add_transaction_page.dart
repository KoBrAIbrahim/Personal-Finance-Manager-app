import 'package:app/Pages/add_transaction_model/widgets/submit_transaction_button.dart';
import 'package:app/Pages/add_transaction_model/widgets/transaction_amount_field.dart';
import 'package:app/Pages/add_transaction_model/widgets/transaction_category_dropdown.dart';
import 'package:app/Pages/add_transaction_model/widgets/transaction_date_picker.dart';
import 'package:app/Pages/add_transaction_model/widgets/transaction_note_field.dart';
import 'package:app/Pages/add_transaction_model/widgets/transaction_type_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTransactionPage extends ConsumerWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add Transaction"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.black12,
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TransactionTypeToggle(),
                SizedBox(height: 24),
                TransactionAmountField(),
                SizedBox(height: 16),
                TransactionCategoryDropdown(),
                SizedBox(height: 16),
                TransactionNoteField(),
                SizedBox(height: 16),
                TransactionDatePicker(),
                SizedBox(height: 24),
                SubmitTransactionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
