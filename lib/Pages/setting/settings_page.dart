import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildTile(
            icon: Icons.person_outline,
            title: 'Account Info',
            onTap: () => context.push('/settings/account'),
            iconColor: theme.iconTheme.color,
            textColor: theme.textTheme.bodyLarge?.color,
          ),
          _buildTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () => context.push('/settings/notifications'),
            iconColor: theme.iconTheme.color,
            textColor: theme.textTheme.bodyLarge?.color,
          ),
          _buildTile(
            icon: Icons.remove_red_eye_outlined,
            title: 'Appearance',
            onTap: () => context.push('/settings/appearance'),
            iconColor: theme.iconTheme.color,
            textColor: theme.textTheme.bodyLarge?.color,
          ),
          _buildTile(
            icon: Icons.language,
            title: 'Region',
            onTap: () => context.push('/settings/region'),
            iconColor: theme.iconTheme.color,
            textColor: theme.textTheme.bodyLarge?.color,
          ),
          _buildTile(
            icon: Icons.lock_outline,
            title: 'Privacy',
            onTap: () => context.push('/settings/privacy'),
            iconColor: theme.iconTheme.color,
            textColor: theme.textTheme.bodyLarge?.color,
          ),
          const SizedBox(height: 30),
          Divider(color: theme.dividerColor),
          _buildTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => context.push('/settings/faq'),
            iconColor: theme.iconTheme.color,
            textColor: theme.textTheme.bodyLarge?.color,
          ),
          _buildTile(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () => context.push('/settings/about'),
            iconColor: theme.iconTheme.color,
            textColor: theme.textTheme.bodyLarge?.color,
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color? iconColor,
    required Color? textColor,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 0),
      ],
    );
  }
}
