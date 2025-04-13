import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goalDetailsProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, goalId) async {
      final doc =
          await FirebaseFirestore.instance
              .collection('goals')
              .doc(goalId)
              .get();
      return doc.exists ? doc.data() : null;
    });

final goalMarkCompletedProvider = Provider((ref) => GoalCompletionController());

class GoalCompletionController {
  Future<void> markAsPurchased(String goalId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('goals').doc(goalId).update({
      'completed': true,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Goal marked as purchased")));

    Navigator.pop(context);
  }
}

class GoalDetailsPage extends ConsumerWidget {
  final String goalId;

  const GoalDetailsPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailsProvider(goalId));
    final completionController = ref.read(goalMarkCompletedProvider);

    return goalAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) =>
              const Scaffold(body: Center(child: Text("Error loading goal."))),
      data: (goalData) {
        if (goalData == null) {
          return const Scaffold(body: Center(child: Text("Goal not found.")));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Goal Details"),
            backgroundColor: const Color(0xFF0077B6),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goalData['title'] ?? 'Goal',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Amount: \$${goalData['amount']}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  "Status: ${goalData['completed'] == true ? 'Completed' :
                   'In Progress'}",
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        goalData['completed'] == true
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),
                const Spacer(),
                if (goalData['completed'] != true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          () => completionController.markAsPurchased(
                            goalId,
                            context,
                          ),
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Mark as Purchased"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
