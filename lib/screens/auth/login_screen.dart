import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  void _switchMode() {
    _ctrl.reset();
    setState(() => _isLogin = !_isLogin);
    _formKey.currentState?.reset();
    context.read<AuthProvider>().clearError();
    _ctrl.forward();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final success = _isLogin
        ? await auth.login(_emailCtrl.text.trim(), _passCtrl.text)
        : await auth.signup(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (success && mounted) Navigator.of(context).pushReplacementNamed('/main');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0,6))]),
              child: const LogoWidget(height: 80)),
            const SizedBox(height: 28),
            Text('StyleMuse', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(_isLogin ? 'Welcome back, style icon ✨' : 'Join your style community ✨',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 32),
            Container(padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight, borderRadius: BorderRadius.circular(30)),
              child: Row(children: [
                Expanded(child: _Tab(label: 'Login', isSelected: _isLogin, onTap: !_isLogin ? _switchMode : null)),
                Expanded(child: _Tab(label: 'Sign Up', isSelected: !_isLogin, onTap: _isLogin ? _switchMode : null)),
              ])),
            const SizedBox(height: 24),
            if (auth.error != null) Container(margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.errorColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.errorColor.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: AppColors.errorColor, size: 18), const SizedBox(width: 10),
                  Expanded(child: Text(auth.error!, style: const TextStyle(color: AppColors.errorColor, fontSize: 13))),
                ])),
            FadeTransition(opacity: _fade, child: Form(key: _formKey,
              child: Column(children: [
                if (!_isLogin) ...[
                  CustomTextField(label: 'Full Name', hint: 'Your name', controller: _nameCtrl, prefixIcon: Icons.person_outline,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
                  const SizedBox(height: 16),
                ],
                CustomTextField(label: 'Email Address', hint: 'your@email.com', controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined,
                    validator: (v) { if (v == null || v.isEmpty) return 'Email is required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email'; return null; }),
                const SizedBox(height: 16),
                CustomTextField(label: 'Password', controller: _passCtrl, isPassword: true, prefixIcon: Icons.lock_outline,
                    validator: (v) { if (v == null || v.isEmpty) return 'Password is required';
                      if (!_isLogin && v.length < 8) return 'Min 8 characters'; return null; }),
              ]))),
            if (_isLogin) Align(alignment: Alignment.centerRight,
                child: TextButton(onPressed: () {}, child: Text('Forgot Password?', style: TextStyle(color: primary, fontSize: 13)))),
            const SizedBox(height: 20),
            PrimaryButton(label: _isLogin ? 'Login' : 'Create Account', onPressed: _submit, isLoading: auth.isLoading),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_isLogin ? "Don't have an account? " : 'Already have an account? ',
                  style: Theme.of(context).textTheme.bodyMedium),
              GestureDetector(onTap: _switchMode,
                  child: Text(_isLogin ? 'Sign Up' : 'Login',
                      style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 14))),
            ]),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label; final bool isSelected; final VoidCallback? onTap;
  const _Tab({required this.label, required this.isSelected, this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(onTap: onTap,
      child: AnimatedContainer(duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppColors.bgDark : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0,2))] : [],
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? primary : AppColors.textSecondaryLight, fontSize: 14))));
  }
}
