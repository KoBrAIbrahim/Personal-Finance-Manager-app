import 'package:app/Pages/spanshot/main_page_widget.dart/snapshot_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeEndDateButton extends ConsumerWidget {
  const ChangeEndDateButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(snapshotControllerProvider.notifier);

    return TextButton.icon(
      onPressed: () => controller.pickEndDate(context),
      icon: const Icon(Icons.date_range),
      label: const Text("Change End Date"),
    );
  }
}
