import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/Pages/edit_transactiom_model/edit_transaction_controller.dart' show currentTransactionProvider, editTransactionControllerProvider;

class SaveTransactionButton extends ConsumerWidget {
  const SaveTransactionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(editTransactionControllerProvider(ref.watch(currentTransactionProvider)));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.isSubmitting ? null : () => controller.submit(context),
        icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
        label: controller.isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Save Changes"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0077B6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
