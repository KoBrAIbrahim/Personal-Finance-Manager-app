import 'package:flutter/material.dart';

class SnapshotAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SnapshotAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Snapshot"),
      backgroundColor: const Color(0xFF0077B6),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
