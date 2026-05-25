import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double height;
  const LogoWidget({Key? key, this.height = 60}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Image.asset(
      'assets/images/logo.jpg',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checkroom_rounded, size: height * 0.7, color: primary),
          const SizedBox(width: 4),
          Text(
            'StyleMuse',
            style: TextStyle(
              fontSize: height * 0.38,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}