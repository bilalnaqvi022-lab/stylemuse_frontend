import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/outfit_model.dart';
import '../theme/app_theme.dart';

class OutfitCard extends StatelessWidget {
  final OutfitModel outfit;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final bool isSaved;
  const OutfitCard({Key? key, required this.outfit, required this.onTap, this.onSave, this.isSaved = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.06), blurRadius: 12, offset: const Offset(0,4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(fit: StackFit.expand, children: [
              CachedNetworkImage(imageUrl: outfit.imageUrl, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                  errorWidget: (_, __, ___) => Container(color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      child: Icon(Icons.checkroom_outlined, size: 32, color: primary.withOpacity(0.3)))),
              if (outfit.isTrending) Positioned(top: 8, left: 8,
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)),
                      child: const Text('🔥', style: TextStyle(fontSize: 10)))),
              Positioned(top: 8, right: 8,
                child: GestureDetector(onTap: onSave,
                  child: Container(width: 30, height: 30,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 16, color: isSaved ? primary : Colors.grey[600])))),
            ]))),
          Padding(padding: const EdgeInsets.fromLTRB(10,8,10,10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(outfit.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(outfit.styleTag, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary, fontWeight: FontWeight.w600))),
            ])),
        ]),
      ));
  }
}
