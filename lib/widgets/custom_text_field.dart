import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;

  const CustomTextField({Key? key, required this.label, this.hint, this.controller,
      this.isPassword = false, this.keyboardType = TextInputType.text,
      this.validator, this.prefixIcon, this.maxLines = 1, this.enabled = true,
      this.onChanged}) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;
  @override
  void initState() { super.initState(); _obscure = widget.isPassword; }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)) : null,
        suffixIcon: widget.isPassword ? IconButton(
          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          onPressed: () => setState(() => _obscure = !_obscure)) : null,
      ),
    );
  }
}
