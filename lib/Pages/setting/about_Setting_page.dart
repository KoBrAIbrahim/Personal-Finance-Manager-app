import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("App Version"),
            subtitle: Text("1.0.0"),
          ),
          const Divider(),

          ExpansionTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text("Privacy Policy"),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "We respect your privacy. Your data is stored securely and never shared.",
                ),
              ),
            ],
          ),
          const Divider(),

          ExpansionTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("Terms & Conditions"),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "By using this app, you agree to our terms of service and usage guidelines.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
