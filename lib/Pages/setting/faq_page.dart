import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  final List<Map<String, String>> _faqList = const [
    {
      'question': 'How do I add a transaction?',
      'answer': 'From the dashboard, tap the (+) button and fill out the transaction details.'
    },
    {
      'question': 'How can I change my password?',
      'answer': 'Go to Settings > Account > Change Password.'
    },
    {
      'question': 'Is my data saved automatically?',
      'answer': 'Yes, all data is automatically saved to Firebase and accessible from any device.'
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, you can delete your account entirely from the Privacy Settings section.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Frequently Asked Questions"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _faqList.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final faq = _faqList[index];
          return ExpansionTile(
            title: Text(
              faq['question']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(faq['answer']!),
              ),
            ],
          );
        },
      ),
    );
  }
}
