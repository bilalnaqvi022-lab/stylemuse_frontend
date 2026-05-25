import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/closet_provider.dart';
import '../providers/calendar_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/logo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl, _textCtrl;
  late Animation<double> _logoFade, _logoScale, _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _textFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.checkAuthStatus();
    await context.read<ClosetProvider>().loadItems();
    await context.read<CalendarProvider>().load();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(auth.isLoggedIn ? '/main' : '/login');
  }

  @override
  void dispose() { _logoCtrl.dispose(); _textCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedBuilder(animation: _logoCtrl, builder: (_, child) => FadeTransition(opacity: _logoFade,
            child: ScaleTransition(scale: _logoScale, child: child)),
          child: Container(padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: primary.withOpacity(0.1), blurRadius: 24, offset: const Offset(0,8))]),
            child: const LogoWidget(height: 120))),
        const SizedBox(height: 32),
        FadeTransition(opacity: _textFade, child: SlideTransition(position: _textSlide,
          child: Column(children: [
            Text('StyleMuse', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Your Personal Style Companion', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
          ]))),
        const SizedBox(height: 60),
        FadeTransition(opacity: _textFade, child: SizedBox(width: 40,
            child: LinearProgressIndicator(backgroundColor: primary.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(primary)))),
      ])),
    );
  }
}
