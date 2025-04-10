import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FB),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF0077B6),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildTile(
            icon: Icons.person_outline,
            title: 'Account Info',
            onTap: () => context.push('/settings/account'),
          ),
          _buildTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () => context.push('/settings/notifications'),
          ),
          _buildTile(
            icon: Icons.remove_red_eye_outlined,
            title: 'Appearance',
            onTap: () => context.push('/settings/appearance'),
          ),
          _buildTile(
            icon: Icons.language,
            title: 'Region',
            onTap: () => context.push('/settings/region'),
          ),
          _buildTile(
            icon: Icons.lock_outline,
            title: 'Privacy',
            onTap: () => context.push('/settings/privacy'),
          ),
          const SizedBox(height: 30),
          const Divider(),
          _buildTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => context.push('/settings/faq'),
          ),
          _buildTile(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () => context.push('/settings/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 0),
      ],
    );
  }
}
