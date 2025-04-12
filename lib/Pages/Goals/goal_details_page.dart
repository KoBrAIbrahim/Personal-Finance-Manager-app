import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GoalDetailsPage extends StatefulWidget {
  final String goalId;

  const GoalDetailsPage({super.key, required this.goalId});

  @override
  State<GoalDetailsPage> createState() => _GoalDetailsPageState();
}

class _GoalDetailsPageState extends State<GoalDetailsPage> {
  Map<String, dynamic>? _goalData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final doc = await FirebaseFirestore.instance
        .collection('goals')
        .doc(widget.goalId)
        .get();

    if (doc.exists) {
      setState(() {
        _goalData = doc.data();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsPurchased() async {
    await FirebaseFirestore.instance
        .collection('goals')
        .doc(widget.goalId)
        .update({'completed': true});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Goal marked as purchased ✅")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_goalData == null) {
      return const Scaffold(
        body: Center(child: Text("Goal not found.")),
      );
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
            Text("🎯 ${_goalData!['title'] ?? 'Goal'}",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("Amount: \$${_goalData!['amount']}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text(
              "Status: ${_goalData!['completed'] == true ? '✅ Completed' : '⏳ In Progress'}",
              style: TextStyle(
                fontSize: 16,
                color: _goalData!['completed'] == true ? Colors.green : Colors.orange,
              ),
            ),
            const Spacer(),
            if (_goalData!['completed'] != true)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _markAsPurchased,
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
  }
}
