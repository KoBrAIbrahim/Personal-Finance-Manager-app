import 'package:app/Pages/edit_transactiom_model/edit_transaction_amount_field.dart';
import 'package:app/Pages/edit_transactiom_model/edit_transaction_category_dropdown.dart';
import 'package:app/Pages/edit_transactiom_model/edit_transaction_controller.dart';
import 'package:app/Pages/edit_transactiom_model/edit_transaction_date_picker.dart';
import 'package:app/Pages/edit_transactiom_model/edit_transaction_note_field.dart';
import 'package:app/Pages/edit_transactiom_model/edit_transaction_type_toggle.dart';
import 'package:app/Pages/edit_transactiom_model/save_transaction_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditTransactionPage extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const EditTransactionPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        currentTransactionProvider.overrideWithValue(transaction),
      ],
      child: const _EditTransactionContent(),
    );
  }
}

class _EditTransactionContent extends ConsumerWidget {
  const _EditTransactionContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, theme),
      body: Stack(
        children: [
          _backgroundCircles(context),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditTransactionTypeToggle(),
                    SizedBox(height: 24),
                    EditTransactionAmountField(),
                    SizedBox(height: 16),
                    EditTransactionCategoryDropdown(),
                    SizedBox(height: 16),
                    EditTransactionNoteField(),
                    SizedBox(height: 16),
                    EditTransactionDatePicker(),
                    SizedBox(height: 28),
                    SaveTransactionButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          boxShadow: const [
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
    );
  }

  Widget _backgroundCircles(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: _circleDecoration(
            200,
            (isDark ? Colors.blue : const Color(0xFF00B4D8)).withOpacity(0.2),
          ),
        ),
        Positioned(
          bottom: -120,
          right: -120,
          child: _circleDecoration(
            250,
            (isDark ? Colors.lightBlueAccent : const Color(0xFF0077B6)).withOpacity(0.2),
          ),
        ),
      ],
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
