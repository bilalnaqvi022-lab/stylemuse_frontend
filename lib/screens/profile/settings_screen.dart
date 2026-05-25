// ignore_for_file: unused_local_variable, use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = context.watch<ThemeProvider>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const LogoWidget(height: 34),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),

          _Section(title: 'Appearance', icon: Icons.palette_outlined, isDark: isDark, children: [
            _ToggleTile(icon: isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                label: 'Dark Mode', subtitle: isDark ? 'Dark theme active' : 'Light theme active',
                value: theme.isDark, onChanged: (_) => theme.toggleTheme()),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Notifications', icon: Icons.notifications_outlined, isDark: isDark, children: [
            _ToggleTile(icon: Icons.notifications_active_outlined,
                label: 'Push Notifications', subtitle: 'Style tips, new outfits, and more',
                value: theme.notificationsEnabled, onChanged: (_) => theme.toggleNotifications()),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Privacy & Data', icon: Icons.shield_outlined, isDark: isDark, children: [
            _TapTile(icon: Icons.lock_outline, label: 'Privacy Policy',
                onTap: () => _showPrivacy(context)),
            _TapTile(icon: Icons.info_outline, label: 'About StyleMuse',
                onTap: () => showAboutDialog(context: context, applicationName: 'StyleMuse',
                    applicationVersion: '1.0.0', applicationIcon: const LogoWidget(height: 48),
                    children: [const Text('Your personal AI-powered fashion companion.')])),
            _TapTile(icon: Icons.delete_outline, label: 'Clear App Data',
                isDestructive: true, onTap: () => _clearData(context)),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Account', icon: Icons.person_outline, isDark: isDark, children: [
            _TapTile(icon: Icons.logout, label: 'Logout', isDestructive: true,
                onTap: () => _logout(context)),
          ]),

          const SizedBox(height: 32),
          Center(child: Column(children: [
            const LogoWidget(height: 44),
            const SizedBox(height: 8),
            Text('StyleMuse v1.0.0', style: Theme.of(context).textTheme.bodySmall),
            Text('Made with ❤️ for fashion lovers',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
          ])),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  void _showPrivacy(BuildContext context) => showDialog(context: context, builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: const Text('Privacy Policy'),
    content: const Text('Your data is stored securely on your device. We use encrypted storage for all sensitive information. We do not sell your personal data.'),
    actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
  ));

  void _clearData(BuildContext context) => showDialog(context: context, builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: const Text('Clear App Data'),
    content: const Text('This will remove all saved outfits and closet items. This cannot be undone.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
          onPressed: () { Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App data cleared'))); },
          child: const Text('Clear')),
    ],
  ));

  void _logout(BuildContext context) => showDialog(context: context, builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: const Text('Logout'),
    content: const Text('Are you sure you want to logout?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
          onPressed: () async {
            Navigator.pop(context);
            await context.read<AuthProvider>().logout();
            if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
          }, child: const Text('Logout')),
    ],
  ));
}

class _Section extends StatelessWidget {
  final String title; final IconData icon; final bool isDark; final List<Widget> children;
  const _Section({required this.title, required this.icon, required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(icon, size: 15, color: primary.withOpacity(0.6)), const SizedBox(width: 6),
          Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: primary.withOpacity(0.7), letterSpacing: 1, fontWeight: FontWeight.w700)),
        ])),
      Container(decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight)),
        child: Column(children: children.asMap().entries.map((e) => Column(children: [
          e.value,
          if (e.key < children.length - 1)
            Divider(height: 1, indent: 56, endIndent: 16,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
        ])).toList())),
    ]);
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon; final String label, subtitle; final bool value; final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 34, height: 34,
          decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 17, color: primary)),
      title: Text(label, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Switch(value: value, onChanged: onChanged));
  }
}

class _TapTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final bool isDestructive;
  const _TapTile({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = isDestructive ? AppColors.errorColor : null;
    return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 34, height: 34,
          decoration: BoxDecoration(color: (color ?? primary).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 17, color: color ?? primary)),
      title: Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
      trailing: Icon(Icons.chevron_right, size: 17, color: (color ?? primary).withOpacity(0.4)),
      onTap: onTap);
  }
}
