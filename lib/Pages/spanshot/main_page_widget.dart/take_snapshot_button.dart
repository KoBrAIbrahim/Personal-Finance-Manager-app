import 'package:app/Pages/spanshot/main_page_widget.dart/snapshot_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TakeSnapshotButton extends ConsumerWidget {
  const TakeSnapshotButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(snapshotControllerProvider.notifier);

    return ElevatedButton.icon(
      onPressed: () => controller.takeSnapshot(context),
      icon: const Icon(Icons.camera),
      label: const Text("Take Snapshot"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00B4D8),
      ),
    );
  }
}
