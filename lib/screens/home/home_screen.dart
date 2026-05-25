// ignore_for_file: use_super_parameters, unused_element, deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart' show Alignment, AnimatedContainer, Axis, Border, BorderRadius, BoxDecoration, BoxFit, BoxShadow, BoxShape, Brightness, BuildContext, Center, CircularProgressIndicator, ClipRRect, Colors, Column, Container, CrossAxisAlignment, CustomScrollView, EdgeInsets, Expanded, FontWeight, GestureDetector, Icon, IconButton, IconData, Icons, Key, LinearGradient, ListTile, ListView, MainAxisAlignment, MainAxisSize, MaterialPageRoute, Navigator, Offset, Padding, Positioned, Radius, RefreshIndicator, RoundedRectangleBorder, Row, Scaffold, ScaffoldMessenger, SearchDelegate, SizedBox, SliverAppBar, SliverFillRemaining, SliverToBoxAdapter, SnackBar, Spacer, Stack, StackFit, State, StatefulWidget, StatelessWidget, Text, TextEditingController, TextOverflow, TextStyle, Theme, VoidCallback, Widget, showModalBottomSheet, showSearch;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/outfit_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/closet_provider.dart';
import '../../services/outfit_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';
import 'outfit_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OutfitService _service = OutfitService();
  List<OutfitModel> _outfits = [];
  List<OutfitModel> _trending = [];
  bool _loading = true;
  String _selectedTag = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  List<OutfitModel> _filtered = [];

  final List<String> _tags = [
    'All', 'Casual', 'Formal', 'Bohemian', 'Streetwear',
    'Minimal', 'Evening', 'Resort', 'Athleisure', 'Academic',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await _service.getOutfits();
    final trend = await _service.getTrendingOutfits();
    if (mounted) {
      setState(() {
        _outfits = all;
        _trending = trend;
        _filtered = all;
        _loading = false;
      });
    }
  }

  void _filterTag(String tag) {
    setState(() {
      _selectedTag = tag;
      _filtered = tag == 'All'
          ? _outfits
          : _outfits.where((o) => o.styleTag == tag).toList();
    });
  }

  void _search(String q) {
    final query = q.toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? (_selectedTag == 'All'
              ? _outfits
              : _outfits.where((o) => o.styleTag == _selectedTag).toList())
          : _outfits.where((o) =>
              o.title.toLowerCase().contains(query) ||
              o.styleTag.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final user = context.watch<AuthProvider>().currentUser;
    final closet = context.watch<ClosetProvider>();
    final firstName = user?.name.split(' ').first ?? 'Stylist';

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // ── Top App Bar ──
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
              elevation: 0,
              title: const LogoWidget(height: 34),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => _showSearch(context),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () => _showNotifications(context),
                ),
                const SizedBox(width: 4),
              ],
            ),

            // ── Greeting ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      firstName,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: GestureDetector(
                  onTap: () => _showSearch(context),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Icon(Icons.search_rounded,
                            size: 20,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        const SizedBox(width: 10),
                        Text(
                          'Search styles, occasions...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Category filter chips ──
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _tags.length,
                      itemBuilder: (_, i) {
                        final tag = _tags[i];
                        final sel = _selectedTag == tag;
                        return GestureDetector(
                          onTap: () => _filterTag(tag),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 7),
                            decoration: BoxDecoration(
                              color: sel
                                  ? primary
                                  : (isDark
                                      ? AppColors.cardDark
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel
                                    ? primary
                                    : (isDark
                                        ? AppColors.dividerDark
                                        : AppColors.dividerLight),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: sel
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                                fontSize: 13,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── AI Pick of the Day ──
            if (!_loading && _trending.isNotEmpty)
              SliverToBoxAdapter(
                child: _SectionBlock(
                  title: '✨ AI Pick for Today',
                  actionLabel: 'See all',
                  onAction: () {},
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _trending.length,
                      itemBuilder: (_, i) => _HeroOutfitCard(
                        outfit: _trending[i],
                        isSaved: closet.isOutfitSaved(_trending[i].id),
                        onTap: () => _open(_trending[i]),
                        onSave: () => _toggleSave(_trending[i]),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Discover / all outfits horizontal rows by style ──
            if (!_loading)
              ..._buildStyleRows(context, closet),

            // ── Empty state ──
            if (!_loading && _filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 56,
                          color: primary.withOpacity(0.25)),
                      const SizedBox(height: 16),
                      Text('No outfits found',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Try a different style or search',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),

            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStyleRows(BuildContext context, ClosetProvider closet) {
    // Group outfits by style tag
    final Map<String, List<OutfitModel>> grouped = {};
    for (final o in _filtered) {
      grouped.putIfAbsent(o.styleTag, () => []).add(o);
    }

    if (_selectedTag != 'All') {
      // Single horizontal row for filtered tag
      final outfits = _filtered;
      return [
        SliverToBoxAdapter(
          child: _SectionBlock(
            title: _selectedTag,
            child: _HorizontalOutfitRow(
              outfits: outfits,
              closet: closet,
              onTap: _open,
              onSave: _toggleSave,
            ),
          ),
        ),
      ];
    }

    // All tags — one row per style
    return grouped.entries.map((entry) {
      return SliverToBoxAdapter(
        child: _SectionBlock(
          title: entry.key,
          actionLabel: 'See all',
          onAction: () => _filterTag(entry.key),
          child: _HorizontalOutfitRow(
            outfits: entry.value,
            closet: closet,
            onTap: _open,
            onSave: _toggleSave,
          ),
        ),
      );
    }).toList();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _open(OutfitModel outfit) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => OutfitDetailScreen(outfit: outfit)));
  }

  void _toggleSave(OutfitModel outfit) {
    final closet = context.read<ClosetProvider>();
    if (closet.isOutfitSaved(outfit.id)) {
      closet.removeOutfit(outfit.id);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Removed from closet')));
    } else {
      closet.saveOutfit(outfit);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('✨ Saved to your closet!')));
    }
  }

  void _showSearch(BuildContext context) {
    showSearch(context: context, delegate: _OutfitSearchDelegate(_outfits, _open));
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _NotifTile(icon: Icons.auto_awesome, title: 'New AI picks ready', subtitle: 'Fresh looks curated for you today', time: '2h ago'),
            _NotifTile(icon: Icons.local_fire_department, title: 'Trending now', subtitle: '5 new outfits are trending this week', time: '5h ago'),
            _NotifTile(icon: Icons.calendar_today_outlined, title: "Don't forget to log today's outfit", subtitle: 'Tap to open your style calendar', time: 'Today'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Section block wrapper
// ──────────────────────────────────────────────────
class _SectionBlock extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;

  const _SectionBlock({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              if (actionLabel != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

// ──────────────────────────────────────────────────
// Horizontal outfit row
// ──────────────────────────────────────────────────
class _HorizontalOutfitRow extends StatelessWidget {
  final List<OutfitModel> outfits;
  final ClosetProvider closet;
  final void Function(OutfitModel) onTap;
  final void Function(OutfitModel) onSave;

  const _HorizontalOutfitRow({
    required this.outfits,
    required this.closet,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: outfits.length,
        itemBuilder: (_, i) => _AclosetOutfitCard(
          outfit: outfits[i],
          isSaved: closet.isOutfitSaved(outfits[i].id),
          onTap: () => onTap(outfits[i]),
          onSave: () => onSave(outfits[i]),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Acloset-style outfit card (portrait, horizontal scroll)
// ──────────────────────────────────────────────────
class _AclosetOutfitCard extends StatelessWidget {
  final OutfitModel outfit;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const _AclosetOutfitCard({
    required this.outfit,
    required this.isSaved,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: CachedNetworkImage(
                      imageUrl: outfit.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        child: Icon(Icons.checkroom_outlined,
                            size: 32, color: primary.withOpacity(0.3)),
                      ),
                    ),
                  ),
                  // Trending badge
                  if (outfit.isTrending)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('🔥',
                            style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  // Save button
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: onSave,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 16,
                          color: isSaved ? primary : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(outfit.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(outfit.styleTag,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Hero card for trending (wider)
// ──────────────────────────────────────────────────
class _HeroOutfitCard extends StatelessWidget {
  final OutfitModel outfit;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const _HeroOutfitCard({
    required this.outfit,
    required this.isSaved,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: outfit.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  child: Icon(Icons.checkroom_outlined, size: 48, color: primary.withOpacity(0.3)),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              // Info at bottom
              Positioned(
                bottom: 14, left: 14, right: 14,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(outfit.styleTag,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 5),
                          Text(outfit.title,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                          Text('${outfit.items.length} items',
                              style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onSave,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 18,
                          color: isSaved ? primary : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Search delegate
// ──────────────────────────────────────────────────
class _OutfitSearchDelegate extends SearchDelegate<OutfitModel?> {
  final List<OutfitModel> outfits;
  final void Function(OutfitModel) onSelected;

  _OutfitSearchDelegate(this.outfits, this.onSelected);

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final q = query.toLowerCase();
    final results = q.isEmpty
        ? outfits
        : outfits.where((o) =>
            o.title.toLowerCase().contains(q) ||
            o.styleTag.toLowerCase().contains(q)).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final o = results[i];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: o.imageUrl,
              width: 48, height: 48,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.checkroom_outlined),
            ),
          ),
          title: Text(o.title),
          subtitle: Text(o.styleTag),
          onTap: () { close(context, o); onSelected(o); },
        );
      },
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final String time;
  const _NotifTile({required this.icon, required this.title, required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(width: 40, height: 40,
          decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: primary, size: 20)),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Text(time, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
