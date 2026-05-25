// ignore_for_file: deprecated_member_use, use_super_parameters, curly_braces_in_flow_control_structures, prefer_const_constructors

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/outfit_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';

class CameraOverlayScreen extends StatefulWidget {
  final OutfitModel? outfit;
  const CameraOverlayScreen({Key? key, this.outfit}) : super(key: key);
  @override State<CameraOverlayScreen> createState() => _CameraOverlayScreenState();
}

class _CameraOverlayScreenState extends State<CameraOverlayScreen> with TickerProviderStateMixin {
  CameraController? _cam;
  bool _initialized = false, _hasPermission = false, _isFront = true, _flashOn = false;
  bool _showPalette = true, _showItems = true, _showTag = true;
  int _activeItem = 0;
  String? _capturedPath;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  static const Map<String, List<Color>> _palettes = {
    'Casual':     [Color(0xFFF5E6D3), Color(0xFFD4B896), Color(0xFF8B7355), Color(0xFF4A4A4A)],
    'Formal':     [Color(0xFF1A1A2E), Color(0xFF2C3E6B), Color(0xFFF0ECD8), Color(0xFFC9A84C)],
    'Bohemian':   [Color(0xFFD4956A), Color(0xFF8B6F47), Color(0xFF4E7C59), Color(0xFFF2DEB4)],
    'Streetwear': [Color(0xFF1C1C1C), Color(0xFF3D3D3D), Color(0xFFE8E8E8), Color(0xFFFF4444)],
    'Minimal':    [Color(0xFFF8F5F0), Color(0xFFE8E0D0), Color(0xFFB8A89A), Color(0xFF6B5B4E)],
    'Evening':    [Color(0xFF1A0A2E), Color(0xFF7B2D8B), Color(0xFFDDB8E8), Color(0xFFFFD700)],
    'Resort':     [Color(0xFF006994), Color(0xFF40B4D8), Color(0xFFF5DEB3), Color(0xFFFF8C69)],
    'Athleisure': [Color(0xFF2D2D2D), Color(0xFF4A90D9), Color(0xFFE8E8E8), Color(0xFF00C896)],
    'Academic':   [Color(0xFF2C1810), Color(0xFF8B6914), Color(0xFF1B3A6B), Color(0xFFF5E6CC)],
    'Feminine':   [Color(0xFFFFB7C5), Color(0xFFE8789A), Color(0xFFF9E4EC), Color(0xFF9B5E7A)],
    'Seasonal':   [Color(0xFF8B4513), Color(0xFFD2691E), Color(0xFFF4A460), Color(0xFF2F4F2F)],
  };

  List<Color> get _palette => _palettes[widget.outfit?.styleTag] ??
      [AppColors.primaryLight, AppColors.accentLight, AppColors.sageGreen, AppColors.bgLight];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _requestAndInit();
  }

  Future<void> _requestAndInit() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() => _hasPermission = status.isGranted);
    if (status.isGranted) await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final desc = _isFront
          ? cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first)
          : cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      _cam?.dispose();
      _cam = CameraController(desc, ResolutionPreset.high, enableAudio: false,
          imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888);
      await _cam!.initialize();
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  Future<void> _switchCamera() async {
    setState(() { _isFront = !_isFront; _initialized = false; });
    await _initCamera();
  }

  Future<void> _toggleFlash() async {
    if (_cam == null || !_cam!.value.isInitialized) return;
    try {
      _flashOn = !_flashOn;
      await _cam!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    } catch (_) {}
  }

  Future<void> _capture() async {
    if (_cam == null || !_cam!.value.isInitialized || _cam!.value.isTakingPicture) return;
    try {
      final file = await _cam!.takePicture();
      if (mounted) { setState(() => _capturedPath = file.path); _showPreview(file.path); }
    } catch (_) {}
  }

  void _showPreview(String path) {
    showModalBottomSheet(context: context, backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          ClipRRect(borderRadius: BorderRadius.circular(16),
              child: Image.file(File(path), height: 260, width: double.infinity, fit: BoxFit.cover)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white30), foregroundColor: Colors.white70),
                child: const Text('Retake'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(
                onPressed: () { Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📸 Style photo saved!'))); },
                icon: const Icon(Icons.save_alt, size: 16), label: const Text('Save'))),
          ]),
        ])));
  }

  @override
  void dispose() { _cam?.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final outfit = widget.outfit;
    if (!_hasPermission) return _NoPermission(onRetry: _requestAndInit);

    return Scaffold(backgroundColor: Colors.black,
      body: Stack(children: [
        if (_initialized && _cam != null) Positioned.fill(child: CameraPreview(_cam!))
        else Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: Colors.white))),

        // Grid overlay
        if (_initialized) Positioned.fill(child: CustomPaint(painter: _GridPainter())),

        // Palette
        if (_showPalette && _initialized) Positioned(left: 14, top: 0, bottom: 0,
          child: Center(child: Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(20)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Palette', style: TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ..._palette.map((c) => Container(width: 26, height: 26, margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(color: c, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                    boxShadow: [BoxShadow(color: c.withOpacity(0.5), blurRadius: 6)]))),
            ])))),

        // Style tag
        if (_showTag && outfit != null && _initialized)
          SafeArea(child: Align(alignment: Alignment.topCenter, child: Padding(padding: const EdgeInsets.only(top: 64),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.15))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 13), const SizedBox(width: 6),
                Text(outfit.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(outfit.styleTag, style: const TextStyle(color: Colors.white70, fontSize: 10))),
              ]))))),

        // Item cards
        if (_showItems && outfit != null && _initialized) Positioned(right: 14, top: 0, bottom: 0,
          child: Center(child: Column(mainAxisSize: MainAxisSize.min,
            children: outfit.items.take(4).toList().asMap().entries.map((e) {
              final i = e.key; final item = e.value; final sel = i == _activeItem;
              return GestureDetector(onTap: () => setState(() => _activeItem = i),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? Colors.white.withOpacity(0.92) : Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? Colors.transparent : Colors.white.withOpacity(0.2))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(item.category, style: TextStyle(color: sel ? Colors.black54 : Colors.white54, fontSize: 9, fontWeight: FontWeight.w600)),
                    ConstrainedBox(constraints: const BoxConstraints(maxWidth: 88),
                      child: Text(item.name, style: TextStyle(color: sel ? Colors.black : Colors.white, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (item.price != null) Text(item.price!, style: TextStyle(color: sel ? Colors.black87 : Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
                  ])));
            }).toList()))),

        // Top bar
        SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(children: [
            _GlassBtn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
                child: const LogoWidget(height: 22)),
            const Spacer(),
            _GlassBtn(icon: _flashOn ? Icons.flash_on : Icons.flash_off, onTap: _toggleFlash, active: _flashOn),
            const SizedBox(width: 8),
            _GlassBtn(icon: Icons.flip_camera_ios_outlined, onTap: _switchCamera),
          ]))),

        // Bottom controls
        Positioned(bottom: 0, left: 0, right: 0,
          child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _ToggleChip(label: 'Palette', active: _showPalette, onTap: () => setState(() => _showPalette = !_showPalette)),
                const SizedBox(width: 8),
                _ToggleChip(label: 'Style', active: _showTag, onTap: () => setState(() => _showTag = !_showTag)),
                const SizedBox(width: 8),
                _ToggleChip(label: 'Items', active: _showItems, onTap: () => setState(() => _showItems = !_showItems)),
              ]),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(width: 64), const Spacer(),
                GestureDetector(onTap: _capture, child: ScaleTransition(scale: _pulse,
                  child: Container(width: 70, height: 70,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3),
                        color: Colors.white.withOpacity(0.15)),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 28)))),
                const Spacer(),
                if (_capturedPath != null)
                  GestureDetector(onTap: () => _showPreview(_capturedPath!),
                    child: ClipRRect(borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_capturedPath!), width: 50, height: 50, fit: BoxFit.cover)))
                else const SizedBox(width: 50),
              ]),
            ])))),
      ]),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.06)..strokeWidth = 0.8;
    for (int i = 0; i <= 3; i++) canvas.drawLine(Offset(size.width*i/3, 0), Offset(size.width*i/3, size.height), p);
    for (int j = 0; j <= 3; j++) canvas.drawLine(Offset(0, size.height*j/3), Offset(size.width, size.height*j/3), p);
    final bp = Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 1.5;
    const m = 20.0; const l = 18.0;
    canvas.drawLine(Offset(m, m), Offset(m+l, m), bp); canvas.drawLine(Offset(m, m), Offset(m, m+l), bp);
    canvas.drawLine(Offset(size.width-m, m), Offset(size.width-m-l, m), bp); canvas.drawLine(Offset(size.width-m, m), Offset(size.width-m, m+l), bp);
    canvas.drawLine(Offset(m, size.height-m), Offset(m+l, size.height-m), bp); canvas.drawLine(Offset(m, size.height-m), Offset(m, size.height-m-l), bp);
    canvas.drawLine(Offset(size.width-m, size.height-m), Offset(size.width-m-l, size.height-m), bp);
    canvas.drawLine(Offset(size.width-m, size.height-m), Offset(size.width-m, size.height-m-l), bp);
  }
  @override bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GlassBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final bool active;
  const _GlassBtn({required this.icon, required this.onTap, this.active = false});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(width: 38, height: 38,
      decoration: BoxDecoration(color: active ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.55),
          shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 18)));
}

class _ToggleChip extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _ToggleChip({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? Colors.transparent : Colors.white.withOpacity(0.3))),
      child: Text(label, style: TextStyle(color: active ? Colors.black : Colors.white,
          fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w400))));
}

class _NoPermission extends StatelessWidget {
  final VoidCallback onRetry;
  const _NoPermission({required this.onRetry});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black,
    body: Center(child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.camera_alt_outlined, size: 72, color: Colors.white38),
        const SizedBox(height: 20),
        const Text('Camera Permission Required', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        const Text('StyleMuse needs camera access for the live style overlay.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 14)),
        const SizedBox(height: 28),
        ElevatedButton(onPressed: onRetry, child: const Text('Grant Permission')),
        const SizedBox(height: 10),
        TextButton(onPressed: openAppSettings,
            child: const Text('Open Settings', style: TextStyle(color: Colors.white60))),
      ]))));
}
