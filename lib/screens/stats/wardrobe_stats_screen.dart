import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';

class WardrobeStatsScreen extends StatefulWidget {
  const WardrobeStatsScreen({Key? key}) : super(key: key);

  @override
  State<WardrobeStatsScreen> createState() => _WardrobeStatsScreenState();
}

class _WardrobeStatsScreenState extends State<WardrobeStatsScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.get(ApiConfig.stats);
      if (mounted) setState(() { _stats = data['stats']; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not load stats. Is the backend running?'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
              elevation: 0,
              title: const LogoWidget(height: 32),
              centerTitle: false,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Wardrobe', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text('Stats', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: primary)),
                  const SizedBox(height: 6),
                  Text('See what earns its place in your closet', style: Theme.of(context).textTheme.bodyMedium),
                ]),
              ),
            ),

            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(
                child: Center(child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.cloud_off_outlined, size: 56, color: primary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('Could not load stats', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 16), label: const Text('Retry')),
                  ]),
                )),
              )
            else
              _buildBody(context, isDark, primary),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ]),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark, Color primary) {
    final s = _stats!;
    final totalItems    = s['totalItems'] ?? 0;
    final totalLogged   = s['totalOutfitsLogged'] ?? 0;
    final totalSaved    = s['totalSavedOutfits'] ?? 0;
    final categories    = List<Map<String, dynamic>>.from(s['categoryBreakdown'] ?? []);
    final mostWorn      = List<Map<String, dynamic>>.from(s['mostWorn'] ?? []);
    final leastWorn     = List<Map<String, dynamic>>.from(s['leastWorn'] ?? []);
    final costStats     = s['costStats'] as Map<String, dynamic>?;
    final diversity     = List<Map<String, dynamic>>.from(s['styleDiversity'] ?? []);

    return SliverList(delegate: SliverChildListDelegate([

      // ── Top 3 stat cards ──
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Row(children: [
          Expanded(child: _StatCard(value: '$totalItems',  label: 'Total\nItems',       icon: Icons.checkroom_outlined,      isDark: isDark)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(value: '$totalLogged', label: 'Outfits\nLogged',    icon: Icons.calendar_today_outlined, isDark: isDark)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(value: '$totalSaved',  label: 'Saved\nLooks',       icon: Icons.bookmark_outlined,       isDark: isDark)),
        ]),
      ),

      // ── Category breakdown ──
      if (categories.isNotEmpty) ...[
        _sectionPad(context, 'By Category'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: categories.map((c) => _CategoryBar(
            category:   c['category']?.toString() ?? '',
            count:      (c['count'] as num?)?.toInt() ?? 0,
            percentage: double.tryParse(c['percentage']?.toString() ?? '0') ?? 0,
            isDark: isDark,
          )).toList()),
        ),
      ],

      // ── Cost per wear ──
      _sectionPad(context, 'Cost Per Wear'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: costStats != null
          ? Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight)),
              child: Row(children: [
                _CostBox(label: 'Best Value',  value: '\$${costStats['best']}/wear'),
                _Divider(),
                _CostBox(label: 'Average',     value: '\$${costStats['average']}/wear'),
                _Divider(),
                _CostBox(label: 'Priciest',    value: '\$${costStats['worst']}/wear'),
              ]))
          : _InfoHint('Add a price when logging closet items to track cost-per-wear'),
      ),

      // ── Most worn ──
      _sectionPad(context, '🔥 Most Worn'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: mostWorn.isEmpty
          ? _InfoHint('Log outfits to see your most-worn pieces')
          : Column(children: mostWorn.asMap().entries.map((e) => _WornTile(
              rank:       e.key + 1,
              name:       e.value['name']?.toString() ?? '',
              category:   e.value['category']?.toString() ?? '',
              wearCount:  (e.value['wearCount'] as num?)?.toInt() ?? 0,
              isMostWorn: true,
              isDark:     isDark,
            )).toList()),
      ),

      // ── Least worn ──
      _sectionPad(context, '😴 Least Worn'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: leastWorn.isEmpty
          ? _InfoHint('Add more clothes to see your least-worn items')
          : Column(children: leastWorn.asMap().entries.map((e) => _WornTile(
              rank:       e.key + 1,
              name:       e.value['name']?.toString() ?? '',
              category:   e.value['category']?.toString() ?? '',
              wearCount:  0,
              isMostWorn: false,
              isDark:     isDark,
            )).toList()),
      ),

      // ── Style diversity ──
      if (diversity.isNotEmpty) ...[
        _sectionPad(context, 'Style Diversity'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                  ? [AppColors.primaryDark.withOpacity(0.2), AppColors.accentDark.withOpacity(0.1)]
                  : [AppColors.primaryLight.withOpacity(0.1), AppColors.accentLight.withOpacity(0.05)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primary.withOpacity(0.15))),
            child: Column(children: diversity.take(5).toList().asMap().entries.map((e) =>
              Padding(
                padding: EdgeInsets.only(bottom: e.key < diversity.length - 1 ? 10 : 0),
                child: _DiversityRow(
                  label: e.value['style']?.toString() ?? '',
                  pct: (double.tryParse(e.value['percentage']?.toString() ?? '0') ?? 0) / 100,
                  isDark: isDark,
                ),
              )).toList()),
          ),
        ),
      ],
    ]));
  }

  Widget _sectionPad(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );
}

// ── Widgets ────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value, label; final IconData icon; final bool isDark;
  const _StatCard({required this.value, required this.label, required this.icon, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(children: [
        Icon(icon, color: primary, size: 22),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
      ]),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String category; final int count; final double percentage; final bool isDark;
  const _CategoryBar({required this.category, required this.count, required this.percentage, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(category, style: Theme.of(context).textTheme.titleSmall),
          Text('$count item${count != 1 ? 's' : ''}', style: Theme.of(context).textTheme.bodySmall),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            valueColor: AlwaysStoppedAnimation<Color>(primary))),
      ]),
    );
  }
}

class _CostBox extends StatelessWidget {
  final String label, value;
  const _CostBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
    const SizedBox(height: 4),
    Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
  ]));
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Theme.of(context).dividerColor);
}

class _WornTile extends StatelessWidget {
  final int rank, wearCount; final String name, category; final bool isMostWorn, isDark;
  const _WornTile({required this.rank, required this.name, required this.category,
      required this.wearCount, required this.isMostWorn, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight)),
      child: Row(children: [
        Container(width: 28, height: 28,
          decoration: BoxDecoration(
            color: rank == 1 && isMostWorn ? const Color(0xFFFFD700) : primary.withOpacity(0.1),
            shape: BoxShape.circle),
          child: Center(child: Text('$rank', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
              color: rank == 1 && isMostWorn ? Colors.white : primary)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: Theme.of(context).textTheme.titleSmall),
          Text(category, style: Theme.of(context).textTheme.bodySmall),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isMostWorn ? primary.withOpacity(0.12) : AppColors.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
          child: Text(
            isMostWorn ? '$wearCount wear${wearCount != 1 ? 's' : ''}' : 'Never worn',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: isMostWorn ? primary : AppColors.errorColor))),
      ]),
    );
  }
}

class _DiversityRow extends StatelessWidget {
  final String label; final double pct; final bool isDark;
  const _DiversityRow({required this.label, required this.pct, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(children: [
      SizedBox(width: 80, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: pct.clamp(0.0, 1.0), minHeight: 8,
          backgroundColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          valueColor: AlwaysStoppedAnimation<Color>(primary.withOpacity(0.7))))),
      const SizedBox(width: 10),
      Text('${(pct * 100).toInt()}%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
    ]);
  }
}

class _InfoHint extends StatelessWidget {
  final String text;
  const _InfoHint(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
    ]),
  );
}
