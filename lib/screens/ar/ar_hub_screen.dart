// ignore_for_file: deprecated_member_use, prefer_const_literals_to_create_immutables, unused_import, use_super_parameters, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/outfit_model.dart';
import '../../providers/closet_provider.dart';
import '../../services/outfit_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';
import 'ar_tryon_screen.dart';
import 'camera_overlay_screen.dart';

class ARHubScreen extends StatefulWidget {
  final OutfitModel? outfit;
  const ARHubScreen({Key? key, this.outfit}) : super(key: key);
  @override State<ARHubScreen> createState() => _ARHubScreenState();
}

class _ARHubScreenState extends State<ARHubScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  OutfitModel? _selected;
  List<OutfitModel> _outfits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selected = widget.outfit;
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _load();
  }

  Future<void> _load() async {
    final list = await OutfitService().getOutfits();
    if (mounted) setState(() { _outfits = list; _loading = false;
      if (_selected == null && list.isNotEmpty) _selected = list.first; });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(title: const LogoWidget(height: 34), centerTitle: false,
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight, elevation: 0),
      body: FadeTransition(opacity: _fade, child: SlideTransition(position: _slide,
        child: SingleChildScrollView(padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Style in', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
            Text('Reality', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: primary)),
            const SizedBox(height: 6),
            Text('Try outfits in your space or see your style live', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 28),

            _ModeCard(isDark: isDark, icon: Icons.view_in_ar_rounded, title: 'AR Object Placement',
              subtitle: 'Place a 3D outfit mannequin in your real world space',
              features: ['📐 Surface detection with scan grid', '👆 Tap to place anywhere', '🤌 Pinch to scale, rotate', '📸 Snapshot & save'],
              badgeLabel: 'Live Camera + Gyro', badgeColor: primary,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ARTryOnScreen(outfit: _selected)))),
            const SizedBox(height: 16),

            _ModeCard(isDark: isDark, icon: Icons.camera_enhance_rounded, title: 'Camera Style Overlay',
              subtitle: 'Live camera with outfit palette, item cards & grid overlay',
              features: ['🎨 Colour palette from style tag', '🏷️ Live item cards with prices', '🔀 Toggle overlays on/off', '📸 Capture your styled look'],
              badgeLabel: 'Live Camera', badgeColor: Theme.of(context).colorScheme.secondary,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CameraOverlayScreen(outfit: _selected)))),
            const SizedBox(height: 28),

            // Outfit selector
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Using Outfit', style: Theme.of(context).textTheme.titleMedium),
              if (_selected != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(_selected!.styleTag, style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 12),

            if (_selected != null)
              Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primary.withOpacity(0.3), width: 1.5)),
                child: Row(children: [
                  Container(width: 50, height: 50, decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.checkroom_outlined, color: primary, size: 24)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_selected!.title, style: Theme.of(context).textTheme.titleSmall),
                    Text('${_selected!.items.length} items', style: Theme.of(context).textTheme.bodySmall),
                  ])),
                  TextButton(onPressed: _pickOutfit, child: const Text('Change')),
                ]))
            else
              GestureDetector(onTap: _pickOutfit,
                child: Container(padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight)),
                  child: Row(children: [Icon(Icons.add_circle_outline, color: primary), const SizedBox(width: 12),
                    Text('Select an outfit', style: TextStyle(color: primary))]))),

            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: primary.withOpacity(0.06), borderRadius: BorderRadius.circular(14)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, size: 15, color: primary), const SizedBox(width: 8),
                Expanded(child: Text('Camera Overlay works on any device. AR Placement uses real camera + gyroscope for parallax effect.',
                    style: Theme.of(context).textTheme.bodySmall)),
              ])),
            const SizedBox(height: 40),
          ]),
        ),
      )),
    );
  }

  void _pickOutfit() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.6, maxChildSize: 0.88, minChildSize: 0.4,
        builder: (_, ctrl) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final primary = Theme.of(context).colorScheme.primary;
          return Container(decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              const SizedBox(height: 12),
              Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              Padding(padding: const EdgeInsets.all(20),
                  child: Text('Choose Outfit', style: Theme.of(context).textTheme.headlineSmall)),
              Expanded(child: _loading ? const Center(child: CircularProgressIndicator())
                : ListView.builder(controller: ctrl, padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _outfits.length, itemBuilder: (_, i) {
                      final o = _outfits[i];
                      final isSel = _selected?.id == o.id;
                      return GestureDetector(onTap: () { setState(() => _selected = o); Navigator.pop(context); },
                        child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSel ? primary.withOpacity(0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSel ? primary : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                                width: isSel ? 1.5 : 1)),
                          child: Row(children: [
                            Icon(isSel ? Icons.check_circle : Icons.checkroom_outlined,
                                color: isSel ? primary : primary.withOpacity(0.4), size: 22),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(o.title, style: Theme.of(context).textTheme.titleSmall),
                              Text('${o.styleTag} · ${o.items.length} items', style: Theme.of(context).textTheme.bodySmall),
                            ])),
                          ])));
                    })),
            ]));
        }));
  }
}

class _ModeCard extends StatelessWidget {
  final bool isDark; final IconData icon; final String title, subtitle, badgeLabel; final Color badgeColor;
  final List<String> features; final VoidCallback onTap;
  const _ModeCard({required this.isDark, required this.icon, required this.title, required this.subtitle,
      required this.features, required this.badgeLabel, required this.badgeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: badgeColor.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: badgeColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0,4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: badgeColor, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Container(margin: const EdgeInsets.only(top: 3), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(badgeLabel, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w700))),
            ])),
            Icon(Icons.arrow_forward_ios, size: 14, color: badgeColor.withOpacity(0.5)),
          ]),
          const SizedBox(height: 10),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 4),
              child: Text(f, style: Theme.of(context).textTheme.bodySmall))),
        ])));
  }
}
