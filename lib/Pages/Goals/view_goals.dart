import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewGoalsPage extends StatelessWidget {
  const ViewGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final goalsStream =
        FirebaseFirestore.instance
            .collection('goals')
            .where('userEmail', isEqualTo: userEmail)
            .orderBy('createdAt', descending: true)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Goals"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: goalsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs =
              (snapshot.data?.docs ?? [])..sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                final aExceeded = aData['exceeded'] == true;
                final bExceeded = bData['exceeded'] == true;

                final aCompleted = aData['completed'] == true;
                final bCompleted = bData['completed'] == true;

                if (aExceeded != bExceeded)
                  return bExceeded ? 1 : -1; 
                if (aCompleted != bCompleted)
                  return bCompleted ? 1 : -1; 
                return 0;
              });

          if (docs.isEmpty) {
            return const Center(child: Text("No goals found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final type = data['type'];
              final docId = docs[index].id;
              final isCompleted = data['completed'] == true;
              final isExceeded = data['exceeded'] == true;

              return Card(
                color:
                    isExceeded
                        ? Colors.red[100]
                        : isCompleted
                        ? Colors.green[100]
                        : null,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    type == 'saving'
                        ? "${data['title']} - \$${data['amount']}"
                        : "${data['category']} Limit - \$${data['limit']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isExceeded
                              ? Colors.red[800]
                              : isCompleted
                              ? Colors.green[800]
                              : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Type: ${type == 'saving' ? 'Saving Goal' : 'Expense Limit'}",
                      ),
                      if (type == 'saving' && isCompleted)
                        const Text(
                          "Goal Achieved",
                          style: TextStyle(color: Colors.green),
                        ),
                      if (type == 'expense_limit' && isExceeded)
                        const Text(
                          "Limit Exceeded",
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          _showEditDialog(context, docId, data);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('goals')
                              .doc(docId)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Goal deleted")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final controller = TextEditingController();
    String label = '';
    if (data['type'] == 'saving') {
      controller.text = data['amount'].toString();
      label = "New Saving Amount";
    } else {
      controller.text = data['limit'].toString();
      label = "New Expense Limit";
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Goal"),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: label),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedValue = double.tryParse(controller.text.trim());
                  if (updatedValue == null || updatedValue <= 0) return;

                  await FirebaseFirestore.instance
                      .collection('goals')
                      .doc(docId)
                      .update(
                        data['type'] == 'saving'
                            ? {'amount': updatedValue}
                            : {'limit': updatedValue},
                      );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Goal updated")));
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }
}
