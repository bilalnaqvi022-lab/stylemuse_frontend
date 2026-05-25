import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/closet_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../calendar/style_calendar_screen.dart';
import '../stats/wardrobe_stats_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final auth = context.watch<AuthProvider>();
    final closet = context.watch<ClosetProvider>();
    final calendar = context.watch<CalendarProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar with avatar ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.surfaceDark, AppColors.bgDark]
                        : [AppColors.surfaceLight, AppColors.bgLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // Avatar
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [primary, primary.withOpacity(0.7)],
                              ),
                              boxShadow: [
                                BoxShadow(color: primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _editProfile(context),
                            child: Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.bgDark : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: primary.withOpacity(0.3), width: 2),
                              ),
                              child: Icon(Icons.edit, size: 12, color: primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(user.bio!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                )),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Stats row ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                    blurRadius: 12, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatBox(value: '${closet.allItems.length}', label: 'Items'),
                  _Separator(),
                  _StatBox(value: '${closet.savedOutfits.length}', label: 'Saved'),
                  _Separator(),
                  _StatBox(value: '${calendar.totalLoggedDays}', label: 'Logged'),
                  _Separator(),
                  _StatBox(value: '${user.stylePreferences.length}', label: 'Styles'),
                ],
              ),
            ),
          ),

          // ── Quick actions ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Style\nCalendar',
                      isDark: isDark,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const StyleCalendarScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.bar_chart_rounded,
                      label: 'Wardrobe\nStats',
                      isDark: isDark,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const WardrobeStatsScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.favorite_outline,
                      label: 'My Style\nPrefs',
                      isDark: isDark,
                      onTap: () => _editPreferences(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Style preferences ──
          if (user.stylePreferences.isNotEmpty)
            SliverToBoxAdapter(
              child: _Section(
                title: 'My Style',
                isDark: isDark,
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: user.stylePreferences.map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(p, style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ),
            ),

          // ── Account options ──
          SliverToBoxAdapter(
            child: _Section(
              title: 'Account',
              isDark: isDark,
              child: Column(
                children: [
                  _ActionTile(icon: Icons.person_outline, label: 'Edit Profile',
                      onTap: () => _editProfile(context)),
                  _ActionTile(icon: Icons.notifications_outlined, label: 'Notifications',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                  _ActionTile(icon: Icons.shield_outlined, label: 'Privacy & Security',
                      onTap: () {}),
                  _ActionTile(icon: Icons.help_outline, label: 'Help & Support',
                      onTap: () => _showHelp(context)),
                  _ActionTile(icon: Icons.logout, label: 'Logout',
                      onTap: () => _logout(context), isDestructive: true, showDivider: false),
                ],
              ),
            ),
          ),

          // ── Version ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
              child: Column(
                children: [
                  const LogoWidget(height: 40),
                  const SizedBox(height: 8),
                  Text('StyleMuse v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text('Made with ❤️ for fashion lovers',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;
    final nameCtrl = TextEditingController(text: user.name);
    final bioCtrl = TextEditingController(text: user.bio ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: auth,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24,
              MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Edit Profile', style: Theme.of(context).textTheme.headlineSmall),
                const LogoWidget(height: 26),
              ]),
              const SizedBox(height: 20),
              CustomTextField(label: 'Full Name', controller: nameCtrl, prefixIcon: Icons.person_outline),
              const SizedBox(height: 14),
              CustomTextField(label: 'Bio', hint: 'Your style in a sentence...', controller: bioCtrl, maxLines: 2),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (ctx, a, _) => PrimaryButton(
                  label: 'Save',
                  isLoading: a.isLoading,
                  onPressed: () async {
                    await a.updateProfile(name: nameCtrl.text.trim(), bio: bioCtrl.text.trim());
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _editPreferences(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final current = auth.currentUser?.stylePreferences ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = List<String>.from(current);

    const allStyles = [
      'Casual', 'Formal', 'Minimal', 'Bohemian', 'Streetwear',
      'Feminine', 'Edgy', 'Classic', 'Resort', 'Athleisure',
      'Academic', 'Vintage', 'Romantic', 'Business',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: auth,
        child: StatefulBuilder(builder: (ctx, setS) {
          final primary = Theme.of(ctx).colorScheme.primary;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('My Style', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Pick all that match your vibe', style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: allStyles.map((s) {
                  final sel = selected.contains(s);
                  return GestureDetector(
                    onTap: () => setS(() { sel ? selected.remove(s) : selected.add(s); }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? primary : primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s, style: TextStyle(
                          color: sel ? Colors.white : primary,
                          fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Consumer<AuthProvider>(
                builder: (c, a, _) => PrimaryButton(
                  label: 'Save Preferences',
                  isLoading: a.isLoading,
                  onPressed: () async {
                    await a.updateProfile(stylePreferences: selected);
                    if (c.mounted) Navigator.pop(c);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ]),
          );
        }),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Help & Support'),
        content: const Text(
          '• Discover → browse curated outfits\n'
          '• Closet → add & manage your clothes\n'
          '• Style AI → chat with your AI stylist\n'
          '• Calendar → log daily outfits\n'
          '• Stats → see wardrobe insights\n\n'
          'support@stylemuse.app',
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Got it!')),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value; final String label;
  const _StatBox({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
    const SizedBox(height: 2),
    Text(label, style: Theme.of(context).textTheme.labelSmall),
  ]);
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 32, color: Theme.of(context).dividerColor);
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final bool isDark;
  const _QuickActionCard({required this.icon, required this.label, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
        ),
        child: Column(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: primary, size: 20)),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, height: 1.4)),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title; final Widget child; final bool isDark;
  const _Section({required this.title, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
        ),
        child: child,
      ),
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  final bool isDestructive; final bool showDivider;
  const _ActionTile({required this.icon, required this.label, required this.onTap,
      this.isDestructive = false, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = isDestructive ? AppColors.errorColor : null;
    return Column(children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Container(width: 34, height: 34,
            decoration: BoxDecoration(color: (color ?? primary).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color ?? primary)),
        title: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right, size: 18, color: (color ?? primary).withOpacity(0.4)),
        onTap: onTap,
      ),
      if (showDivider) const Divider(height: 1, indent: 64, endIndent: 16),
    ]);
  }
}
