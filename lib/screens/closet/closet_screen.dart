// ignore_for_file: deprecated_member_use, use_super_parameters, prefer_const_constructors, curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../models/closet_item_model.dart';
import '../../models/outfit_model.dart';
import '../../providers/closet_provider.dart';
import '../../services/image_upload_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../ar/ar_hub_screen.dart';
import '../home/outfit_detail_screen.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({Key? key}) : super(key: key);

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final closet = context.watch<ClosetProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            elevation: 0,
            title: const LogoWidget(height: 34),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ARHubScreen())),
                icon: Icon(Icons.view_in_ar_rounded, color: primary),
                tooltip: 'AR Try-On',
              ),
              IconButton(
                onPressed: () => _showAddSheet(context),
                icon: Icon(Icons.add_circle_outline, color: primary),
                tooltip: 'Add item',
              ),
              const SizedBox(width: 4),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: primary,
              indicatorWeight: 2.5,
              labelColor: primary,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: [
                Tab(text: 'My Clothes (${closet.allItems.length})'),
                Tab(text: 'Saved Looks (${closet.savedOutfits.length})'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _MyClothesTab(closet: closet),
            _SavedLooksTab(closet: closet),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddItemSheet(),
    );
  }
}

// ── My Clothes Tab ─────────────────────────────────────
class _MyClothesTab extends StatelessWidget {
  final ClosetProvider closet;
  const _MyClothesTab({required this.closet});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(children: [
      // Category chips
      Container(
        color: isDark ? AppColors.bgDark : AppColors.bgLight,
        child: SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: ClosetItemModel.categories.length,
            itemBuilder: (_, i) {
              final cat = ClosetItemModel.categories[i];
              final sel = closet.selectedCategory == cat;
              return GestureDetector(
                onTap: () => closet.setCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? primary : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? primary : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                    ),
                  ),
                  child: Text(cat, style: TextStyle(
                    color: sel ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  )),
                ),
              );
            },
          ),
        ),
      ),

      Expanded(
        child: closet.isLoading
            ? const Center(child: CircularProgressIndicator())
            : closet.items.isEmpty
                ? _EmptyState(
                    icon: Icons.checkroom_outlined,
                    title: closet.selectedCategory == 'All'
                        ? 'Your closet is empty'
                        : 'No ${closet.selectedCategory} yet',
                    subtitle: 'Tap + to add your first clothing item',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: closet.items.length,
                    itemBuilder: (_, i) => _ClosetCard(
                      item: closet.items[i],
                      onDelete: () => closet.removeItem(closet.items[i].id),
                    ),
                  ),
      ),
    ]);
  }
}

// ── Saved Looks Tab ────────────────────────────────────
class _SavedLooksTab extends StatelessWidget {
  final ClosetProvider closet;
  const _SavedLooksTab({required this.closet});

  @override
  Widget build(BuildContext context) {
    if (closet.savedOutfits.isEmpty) {
      return _EmptyState(
        icon: Icons.bookmark_outline,
        title: 'No saved looks yet',
        subtitle: 'Browse Discover and save outfits you love',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.7,
        mainAxisSpacing: 14, crossAxisSpacing: 14,
      ),
      itemCount: closet.savedOutfits.length,
      itemBuilder: (context, i) {
        final outfit = closet.savedOutfits[i];
        return _SavedCard(
          outfit: outfit,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => OutfitDetailScreen(outfit: outfit))),
          onRemove: () => closet.removeOutfit(outfit.id),
        );
      },
    );
  }
}

// ── Closet Card ────────────────────────────────────────
class _ClosetCard extends StatelessWidget {
  final ClosetItemModel item;
  final VoidCallback onDelete;

  const _ClosetCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: Container(
                color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
                child: _buildImage(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(item.category,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildImage() {
    if (item.imagePath.isEmpty) return const _PlaceholderIcon();
    // Cloudinary URL from backend
    if (item.imagePath.startsWith('http')) {
      return Image.network(item.imagePath, fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) => progress == null ? child
              : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorBuilder: (_, __, ___) => const _PlaceholderIcon());
    }
    // Local file path (fallback)
    if (!kIsWeb) {
      final f = File(item.imagePath);
      if (f.existsSync()) return Image.file(f, fit: BoxFit.contain);
    }
    return const _PlaceholderIcon();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Remove Item'),
      content: Text('Remove "${item.name}" from your closet?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () { Navigator.pop(context); onDelete(); },
          child: const Text('Remove', style: TextStyle(color: AppColors.errorColor)),
        ),
      ],
    ));
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();
  @override
  Widget build(BuildContext context) => Center(
      child: Icon(Icons.checkroom_outlined, size: 36,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.25)));
}

class _SavedCard extends StatelessWidget {
  final OutfitModel outfit;
  final VoidCallback onTap, onRemove;
  const _SavedCard({required this.outfit, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(fit: StackFit.expand, children: [
              Image.network(outfit.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      child: const _PlaceholderIcon())),
              Positioned(top: 8, right: 8,
                child: GestureDetector(onTap: onRemove,
                  child: Container(width: 28, height: 28,
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), shape: BoxShape.circle),
                      child: const Icon(Icons.bookmark, size: 15, color: Colors.white)))),
            ]),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(outfit.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(outfit.styleTag,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: primary)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Center(child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 64, color: primary.withOpacity(0.2)),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
      ])));
  }
}

// ── Add Item Sheet ─────────────────────────────────────
class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet();
  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _nameCtrl  = TextEditingController();
  final _brandCtrl = TextEditingController();
  String _category = 'Tops';
  String? _localPath;
  String? _uploadedUrl;
  bool _saving = false;
  bool _uploading = false;
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource src) async {
    // Request permission on mobile
    if (!kIsWeb) {
      final perm = src == ImageSource.camera ? Permission.camera : Permission.photos;
      final status = await perm.request();
      if (!status.isGranted) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission required'),
              action: SnackBarAction(label: 'Settings', onPressed: openAppSettings)));
        return;
      }
    }

    try {
      final picked = await _picker.pickImage(source: src, imageQuality: 85, maxWidth: 1080);
      if (picked == null || !mounted) return;

      setState(() { _localPath = picked.path; _uploading = true; _uploadedUrl = null; });

      // Upload to Cloudinary via backend
      String? url;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        url = await ImageUploadService.uploadImage(imageFile: bytes, folder: 'stylemuse/closet');
      } else {
        url = await ImageUploadService.uploadImage(imageFile: File(picked.path), folder: 'stylemuse/closet');
      }

      if (mounted) {
        setState(() {
          _uploadedUrl = url;
          _uploading = false;
        });
        if (url != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Photo uploaded to cloud!')));
        }
      }
    } catch (e) {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an item name')));
      return;
    }
    setState(() => _saving = true);

    // Use cloud URL if uploaded, otherwise local path
    final imagePath = _uploadedUrl ?? _localPath ?? '';

    final item = ClosetItemModel(
      id: _uuid.v4(),
      name: _nameCtrl.text.trim(),
      category: _category,
      imagePath: imagePath,
      addedDate: DateTime.now(),
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
    );

    await context.read<ClosetProvider>().addItem(item);
    setState(() => _saving = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✨ Item added to your closet!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Add to Closet', style: Theme.of(context).textTheme.headlineSmall),
            const LogoWidget(height: 26),
          ]),
          const SizedBox(height: 20),

          // Image area
          Center(
            child: GestureDetector(
              onTap: _uploading ? null : _showSourceSheet,
              child: Container(
                width: 140, height: 170,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withOpacity(0.25), width: 1.5),
                ),
                child: _buildPreview(isDark, primary),
              ),
            ),
          ),

          // Upload status
          if (_uploadedUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_done, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text('Saved to cloud', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.green)),
              ])),
            ),

          const SizedBox(height: 20),

          CustomTextField(label: 'Item Name *', hint: 'e.g. White linen blouse',
              controller: _nameCtrl, prefixIcon: Icons.dry_cleaning_outlined),
          const SizedBox(height: 14),

          Text('Category', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ClosetItemModel.categories.where((c) => c != 'All').map((cat) {
              final sel = _category == cat;
              return GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? primary : primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(cat, style: TextStyle(
                      color: sel ? Colors.white : primary,
                      fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          CustomTextField(label: 'Brand (optional)', hint: 'e.g. Zara',
              controller: _brandCtrl, prefixIcon: Icons.label_outline),
          const SizedBox(height: 24),

          PrimaryButton(
            label: 'Add to My Closet',
            onPressed: (_saving || _uploading) ? null : _save,
            isLoading: _saving,
            icon: Icons.checkroom_outlined,
          ),
        ]),
      ),
    );
  }

  Widget _buildPreview(bool isDark, Color primary) {
    if (_uploading) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(strokeWidth: 2),
        const SizedBox(height: 10),
        Text('Uploading to cloud…',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: primary)),
      ]);
    }
    if (_uploadedUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(_uploadedUrl!, fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    if (_localPath != null && !kIsWeb) {
      final f = File(_localPath!);
      if (f.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(f, fit: BoxFit.contain),
        );
      }
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add_photo_alternate_outlined, size: 38, color: primary.withOpacity(0.5)),
      const SizedBox(height: 8),
      Text('Add Photo', style: TextStyle(color: primary, fontSize: 12)),
      const SizedBox(height: 4),
      Text('Auto-uploads to cloud', style: TextStyle(color: primary.withOpacity(0.5), fontSize: 10)),
    ]);
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Choose Source', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          if (!kIsWeb)
            ListTile(leading: const Icon(Icons.camera_alt_outlined), title: const Text('Take Photo'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
          ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Choose from Gallery'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
        ]),
      ),
    );
  }
}
