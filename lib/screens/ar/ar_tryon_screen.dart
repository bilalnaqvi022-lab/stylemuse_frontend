// ignore_for_file: unused_field, deprecated_member_use, prefer_const_literals_to_create_immutables, use_super_parameters, curly_braces_in_flow_control_structures, prefer_const_constructors

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../models/outfit_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';

class ARTryOnScreen extends StatefulWidget {
  final OutfitModel? outfit;
  const ARTryOnScreen({Key? key, this.outfit}) : super(key: key);
  @override State<ARTryOnScreen> createState() => _ARTryOnScreenState();
}

class _ARTryOnScreenState extends State<ARTryOnScreen> with TickerProviderStateMixin {
  CameraController? _cam;
  bool _initialized = false, _hasPermission = false;
  bool _isPlaced = false, _isScanning = true;
  Offset _pos = const Offset(0.5, 0.5);
  double _scale = 1.0, _rotation = 0.0, _baseScale = 1.0, _baseRot = 0.0;
  double _gyroX = 0.0, _gyroY = 0.0;
  int _selectedItem = 0;
  String? _capturedPath;
  late AnimationController _scanCtrl, _placeCtrl, _pulseCtrl;
  late Animation<double> _scanAnim, _placeAnim, _pulseAnim;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _placeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(_scanCtrl);
    _placeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _placeCtrl, curve: Curves.elasticOut));
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _requestAndInit();
    gyroscopeEventStream().listen((e) {
      if (!mounted) return;
      setState(() {
        _gyroX = (_gyroX + e.x * 0.05).clamp(-0.08, 0.08);
        _gyroY = (_gyroY + e.y * 0.05).clamp(-0.08, 0.08);
      });
    });
  }

  Future<void> _requestAndInit() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() => _hasPermission = status.isGranted);
    if (status.isGranted) await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) return;
      final back = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
      _cam = CameraController(back, ResolutionPreset.high, enableAudio: false,
          imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888);
      await _cam!.initialize();
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  void _onTap(TapDownDetails d, BoxConstraints c) {
    setState(() {
      _pos = Offset(d.localPosition.dx / c.maxWidth, d.localPosition.dy / c.maxHeight);
      _isPlaced = true; _isScanning = false;
    });
    _placeCtrl.reset(); _placeCtrl.forward();
  }

  void _reset() {
    setState(() { _isPlaced = false; _isScanning = true; _scale = 1.0; _rotation = 0.0; });
    _placeCtrl.reset();
  }

  Future<void> _capture() async {
    if (_cam == null || !_cam!.value.isInitialized || _cam!.value.isTakingPicture) return;
    try {
      final file = await _cam!.takePicture();
      if (mounted) { setState(() => _capturedPath = file.path); _showPreview(file.path); }
    } catch (_) {}
  }

  void _showPreview(String path) => showModalBottomSheet(context: context, backgroundColor: Colors.grey[900],
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📸 AR snapshot saved!'))); },
              icon: const Icon(Icons.save_alt, size: 16), label: const Text('Save'))),
        ]),
      ])));

  @override
  void dispose() { _cam?.dispose(); _scanCtrl.dispose(); _placeCtrl.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) return _PermScreen(onRetry: _requestAndInit);
    final outfit = widget.outfit;

    return Scaffold(backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (ctx, constraints) => GestureDetector(
        onTapDown: _isPlaced ? null : (d) => _onTap(d, constraints),
        onScaleStart: (_) { _baseScale = _scale; _baseRot = _rotation; },
        onScaleUpdate: (d) {
          if (!_isPlaced) return;
          setState(() {
            _scale = (_baseScale * d.scale).clamp(0.4, 2.5);
            if (d.pointerCount >= 2) _rotation = _baseRot + d.rotation;
          });
        },
        child: Stack(children: [
          if (_initialized && _cam != null) Positioned.fill(child: CameraPreview(_cam!))
          else Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: Colors.white))),

          if (_isScanning && _initialized) Positioned.fill(
              child: AnimatedBuilder(animation: _scanAnim, builder: (_, __) => CustomPaint(painter: _ScanPainter(_scanAnim.value)))),

          if (_isScanning && _initialized) Positioned.fill(
              child: AnimatedBuilder(animation: _pulseAnim, builder: (_, __) => CustomPaint(painter: _DotsPainter(_pulseAnim.value)))),

          if (_isPlaced && _initialized) AnimatedBuilder(animation: _placeAnim, builder: (_, __) {
            final x = _pos.dx * constraints.maxWidth + _gyroY * 28;
            final y = _pos.dy * constraints.maxHeight + _gyroX * 28;
            final s = _scale * _placeAnim.value;
            return Positioned(left: x - 60*s, top: y - 130*s,
              child: Transform.rotate(angle: _rotation,
                child: Transform.scale(scale: s, child: _Mannequin(outfit: outfit))));
          }),

          // Shadow
          if (_isPlaced && _initialized) AnimatedBuilder(animation: _placeAnim, builder: (_, __) =>
            Positioned(left: _pos.dx*constraints.maxWidth - 38*_scale, top: _pos.dy*constraints.maxHeight + 108*_scale,
              child: Opacity(opacity: 0.3*_placeAnim.value, child: Container(width: 76, height: 14,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(38),
                    boxShadow: [const BoxShadow(color: Colors.black, blurRadius: 10, spreadRadius: 4)]))))),

          // Top bar
          SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(children: [
              _Btn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
              const SizedBox(width: 10),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
                  child: const LogoWidget(height: 22)),
              const Spacer(),
              if (_isPlaced) ...[
                _Btn(icon: Icons.camera_alt_outlined, onTap: _capture),
                const SizedBox(width: 8),
                _Btn(icon: Icons.refresh, onTap: _reset, red: true),
              ],
            ]))),

          Stack(
  children: [

    SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 64),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Icon(
                    _isPlaced ? Icons.check_circle_outline : Icons.radar,
                    color: _isPlaced ? Colors.greenAccent : Colors.white70,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  _isPlaced
                      ? 'Pinch to scale · Two fingers to rotate'
                      : 'Tap anywhere to place the outfit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),

    if (outfit != null)
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: _InfoPanel(
          outfit: outfit,
          selectedIndex: _selectedItem,
          onItemSelected: (i) => setState(() => _selectedItem = i),
        ),
      ),

  ],
)
      ]))));
  }
}

class _Mannequin extends StatelessWidget {
  final OutfitModel? outfit;
  static const Map<String, List<Color>> _colors = {
    'Casual':     [Color(0xFFF5E6D3), Color(0xFFD4B896)],
    'Formal':     [Color(0xFF1A1A2E), Color(0xFF2C3E6B)],
    'Bohemian':   [Color(0xFFD4956A), Color(0xFF8B6F47)],
    'Streetwear': [Color(0xFF1C1C1C), Color(0xFF3D3D3D)],
    'Minimal':    [Color(0xFFF8F5F0), Color(0xFFE8E0D0)],
    'Evening':    [Color(0xFF1A0A2E), Color(0xFF7B2D8B)],
    'Resort':     [Color(0xFF006994), Color(0xFF40B4D8)],
    'Athleisure': [Color(0xFF2D2D2D), Color(0xFF4A90D9)],
    'Academic':   [Color(0xFF2C1810), Color(0xFF8B6914)],
    'Feminine':   [Color(0xFFFFB7C5), Color(0xFFE8789A)],
    'Seasonal':   [Color(0xFF8B4513), Color(0xFFD2691E)],
  };
  const _Mannequin({this.outfit});

  @override
  Widget build(BuildContext context) {
    final cols = _colors[outfit?.styleTag] ?? [AppColors.primaryLight, AppColors.accentLight];
    return SizedBox(width: 120, height: 240,
      child: CustomPaint(painter: _MannequinPainter(cols[0], cols[1], outfit?.styleTag ?? ''),
        child: Align(alignment: Alignment.bottomCenter, child: Container(
          margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), borderRadius: BorderRadius.circular(9)),
          child: Text(outfit?.title ?? 'Outfit', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700), textAlign: TextAlign.center)))));
  }
}

class _MannequinPainter extends CustomPainter {
  final Color top, bottom; final String tag;
  _MannequinPainter(this.top, this.bottom, this.tag);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawOval(Rect.fromCenter(center: Offset(w/2, h*0.42), width: 80, height: 180),
        Paint()..color = top.withOpacity(0.22)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w/2-3, h*0.72, 6, h*0.18), const Radius.circular(3)),
        Paint()..color = Colors.grey[700]!);
    canvas.drawOval(Rect.fromCenter(center: Offset(w/2, h*0.91), width: 52, height: 10), Paint()..color = Colors.grey[600]!);
    final bodyPaint = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom])
        .createShader(Rect.fromLTWH(w*0.2, h*0.12, w*0.6, h*0.6));
    final torso = Path()..moveTo(w*0.35, h*0.18)..cubicTo(w*0.18, h*0.28, w*0.22, h*0.42, w*0.28, h*0.52)
        ..lineTo(w*0.28, h*0.72)..lineTo(w*0.72, h*0.72)..lineTo(w*0.72, h*0.52)
        ..cubicTo(w*0.78, h*0.42, w*0.82, h*0.28, w*0.65, h*0.18)..close();
    canvas.drawPath(torso, bodyPaint);
    canvas.drawPath(torso, Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.43, h*0.10, w*0.14, h*0.09), const Radius.circular(4)),
        Paint()..color = top.withOpacity(0.8));
    canvas.drawCircle(Offset(w/2, h*0.08), w*0.10, Paint()..color = const Color(0xFFE8C9A0));
    canvas.drawCircle(Offset(w/2, h*0.08), w*0.10, Paint()..color = Colors.white.withOpacity(0.18)..style = PaintingStyle.stroke..strokeWidth = 1);
    if (['Casual','Bohemian','Resort','Seasonal'].contains(tag)) {
      canvas.drawOval(Rect.fromCenter(center: Offset(w/2, h*0.045), width: 44, height: 9), Paint()..color = const Color(0xFFB8967A));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w/2-12, h*0.005, 24, h*0.04), const Radius.circular(4)), Paint()..color = const Color(0xFFD4B896));
    }
    if (['Formal','Business','Academic'].contains(tag)) {
      final lp = Paint()..color = bottom.withOpacity(0.9);
      canvas.drawPath(Path()..moveTo(w*0.45, h*0.18)..lineTo(w*0.32, h*0.30)..lineTo(w*0.42, h*0.38)..close(), lp);
      canvas.drawPath(Path()..moveTo(w*0.55, h*0.18)..lineTo(w*0.68, h*0.30)..lineTo(w*0.58, h*0.38)..close(), lp);
    }
    if (['Evening','Feminine','Bohemian','Resort'].contains(tag)) {
      final sp = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [bottom, bottom.withOpacity(0.6)]).createShader(Rect.fromLTWH(w*0.1, h*0.52, w*0.8, h*0.20));
      final skirt = Path()..moveTo(w*0.28, h*0.52)..lineTo(w*0.12, h*0.72)..lineTo(w*0.88, h*0.72)..lineTo(w*0.72, h*0.52)..close();
      canvas.drawPath(skirt, sp);
      canvas.drawPath(skirt, Paint()..color = Colors.white.withOpacity(0.25)..style = PaintingStyle.stroke..strokeWidth = 1.2);
    }
    canvas.drawOval(Rect.fromCenter(center: Offset(w/2, h*0.73), width: 56, height: 10),
        Paint()..color = top.withOpacity(0.45)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawOval(Rect.fromCenter(center: Offset(w/2, h*0.73), width: 72, height: 13),
        Paint()..color = top.withOpacity(0.18)..style = PaintingStyle.stroke..strokeWidth = 1);
  }
  @override bool shouldRepaint(_MannequinPainter old) => old.top != top || old.tag != tag;
}

class _ScanPainter extends CustomPainter {
  final double progress;
  _ScanPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.cyanAccent.withOpacity(0.055)..strokeWidth = 0.8;
    for (int i = 0; i <= 8; i++) canvas.drawLine(Offset(size.width*i/8, 0), Offset(size.width*i/8, size.height), p);
    for (int j = 0; j <= 16; j++) canvas.drawLine(Offset(0, size.height*j/16), Offset(size.width, size.height*j/16), p);
    final y = size.height * progress;
    canvas.drawLine(Offset(0, y), Offset(size.width, y),
        Paint()..shader = LinearGradient(colors: [Colors.transparent, Colors.cyanAccent.withOpacity(0.55), Colors.transparent])
            .createShader(Rect.fromLTWH(0, y-18, size.width, 36))..strokeWidth = 2);
  }
  @override bool shouldRepaint(_ScanPainter old) => old.progress != progress;
}

class _DotsPainter extends CustomPainter {
  final double pulse;
  static const _dots = [Offset(0.22,0.55),Offset(0.50,0.60),Offset(0.75,0.53),Offset(0.35,0.68),
      Offset(0.62,0.70),Offset(0.48,0.78),Offset(0.28,0.74),Offset(0.70,0.65),Offset(0.15,0.62),Offset(0.85,0.58)];
  _DotsPainter(this.pulse);
  @override
  void paint(Canvas canvas, Size size) {
    for (final n in _dots) {
      final p = Offset(n.dx*size.width, n.dy*size.height);
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.cyanAccent.withOpacity(0.5*pulse));
      canvas.drawCircle(p, 6, Paint()..color = Colors.cyanAccent.withOpacity(0.18*pulse)..style = PaintingStyle.stroke..strokeWidth = 1);
    }
  }
  @override bool shouldRepaint(_DotsPainter old) => old.pulse != pulse;
}

class _InfoPanel extends StatelessWidget {
  final OutfitModel outfit; final int selectedIndex; final ValueChanged<int> onItemSelected;
  const _InfoPanel({required this.outfit, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final item = selectedIndex < outfit.items.length ? outfit.items[selectedIndex] : null;
    return Container(padding: const EdgeInsets.fromLTRB(18,12,18,26),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.78),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 34, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Text(outfit.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(outfit.styleTag, style: const TextStyle(color: Colors.white70, fontSize: 10))),
        ]),
        const SizedBox(height: 9),
        SizedBox(height: 30, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: outfit.items.length,
          itemBuilder: (_, i) { final sel = i == selectedIndex;
            return GestureDetector(onTap: () => onItemSelected(i),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 7), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: sel ? Colors.white : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: Text(outfit.items[i].category, style: TextStyle(color: sel ? Colors.black : Colors.white, fontSize: 10,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400))));
          })),
        if (item != null) ...[
          const SizedBox(height: 9),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              if (item.brand != null) Text(item.brand!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ])),
            if (item.price != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                child: Text(item.price!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
          ]),
        ],
      ]));
  }
}

class _Btn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final bool red;
  const _Btn({required this.icon, required this.onTap, this.red = false});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(width: 38, height: 38,
      decoration: BoxDecoration(color: red ? Colors.red.withOpacity(0.75) : Colors.black.withOpacity(0.55),
          shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.18))),
      child: Icon(icon, color: Colors.white, size: 18)));
}

class _PermScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermScreen({required this.onRetry});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black,
    body: Center(child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.view_in_ar_rounded, size: 72, color: Colors.white38), const SizedBox(height: 20),
        const Text('Camera Permission Required', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        const Text('StyleMuse AR needs camera access to place outfit visuals in your space.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 14)),
        const SizedBox(height: 28),
        ElevatedButton(onPressed: onRetry, child: const Text('Grant Permission')),
        const SizedBox(height: 10),
        TextButton(onPressed: openAppSettings, child: const Text('Open Settings', style: TextStyle(color: Colors.white60))),
      ]))));
}
