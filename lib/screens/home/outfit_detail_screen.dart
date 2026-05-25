import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/outfit_model.dart';
import '../../providers/closet_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/custom_button.dart';
import '../ar/ar_hub_screen.dart';
import '../ar/camera_overlay_screen.dart';

class OutfitDetailScreen extends StatelessWidget {
  final OutfitModel outfit;
  const OutfitDetailScreen({Key? key, required this.outfit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final closet = context.watch<ClosetProvider>();
    final isSaved = closet.isOutfitSaved(outfit.id);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: CustomScrollView(slivers: [
        SliverAppBar(expandedHeight: 400, pinned: true,
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          leading: GestureDetector(onTap: () => Navigator.pop(context),
            child: Container(margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white))),
          title: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(16)),
            child: const LogoWidget(height: 26)),
          flexibleSpace: FlexibleSpaceBar(background: Stack(fit: StackFit.expand, children: [
            CachedNetworkImage(imageUrl: outfit.imageUrl, fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    child: const Center(child: Icon(Icons.checkroom_outlined, size: 64)))),
            Container(decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.55)], stops: const [0.5, 1.0]))),
            Positioned(bottom: 20, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(12)),
                  child: Text(outfit.styleTag, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
              const SizedBox(height: 6),
              Text(outfit.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
            ])),
          ]))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Items
            Text('Complete the Look', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            ...outfit.items.map((item) => Container(margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight)),
              child: Row(children: [
                Container(width: 40, height: 40,
                    decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.checkroom_outlined, color: primary, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name, style: Theme.of(context).textTheme.titleSmall),
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(item.category, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary))),
                    if (item.brand != null) ...[const SizedBox(width: 6),
                      Text(item.brand!, style: Theme.of(context).textTheme.bodySmall)],
                  ]),
                ])),
                if (item.price != null) Text(item.price!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: primary, fontWeight: FontWeight.w700)),
              ]))),
            const SizedBox(height: 20),
            // Save button
            PrimaryButton(label: isSaved ? '✓ Saved to My Closet' : '+ Save to My Closet',
              onPressed: () {
                if (isSaved) { closet.removeOutfit(outfit.id);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from closet')));
                } else { closet.saveOutfit(outfit);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✨ Saved to your closet!')));
                }
              }),
            const SizedBox(height: 14),
            // AR buttons
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: primary.withOpacity(0.07), borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withOpacity(0.15))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.view_in_ar_rounded, color: primary, size: 18), const SizedBox(width: 8),
                  Text('Try It On', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: primary))]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CameraOverlayScreen(outfit: outfit))),
                      icon: const Icon(Icons.camera_enhance_outlined, size: 16), label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ARHubScreen(outfit: outfit))),
                      icon: const Icon(Icons.view_in_ar_rounded, size: 16), label: const Text('AR Try-On'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)))),
                ]),
              ])),
            const SizedBox(height: 40),
          ]))),
      ]),
    );
  }
}
