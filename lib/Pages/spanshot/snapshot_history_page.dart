import 'package:app/Pages/spanshot/snapshot_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SnapshotHistoryPage extends StatelessWidget {
  const SnapshotHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final snapshotsStream =
        FirebaseFirestore.instance
            .collection('snapshots')
            .where('userEmail', isEqualTo: userEmail)
            .orderBy('start', descending: true)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Snapshot History"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: snapshotsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("🔥 Firestore Error: ${snapshot.error}");
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No snapshots found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final start = (data['start'] as Timestamp).toDate();
              final end = (data['end'] as Timestamp).toDate();
              final balance = (data['balance'] ?? 0).toDouble();
              final createdAt = (data['createdAt'] as Timestamp).toDate();

              final isPositive = balance >= 0;
              final balanceColor = isPositive ? Colors.green : Colors.red;

              return InkWell(
                onTap: () {
                  final docId = docs[index].id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SnapshotDetailsPage(snapshotId: docId),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Period: ${DateFormat.yMMMd().format(start)} - ${DateFormat.yMMMd().format(end)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Balance: \$${balance.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: balanceColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Created: ${DateFormat.yMMMd().add_jm().format(createdAt)}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
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
}
