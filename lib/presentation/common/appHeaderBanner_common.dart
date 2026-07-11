// lib/widgets/common/app_header_banner.dart
import 'package:flutter/material.dart';

import '../../core/themes/app_color.dart';

class AppHeaderBanner extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppHeaderBanner({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 50, 20, 24),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: CdaColors.vertForet,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: child,
        ),
      ),
    );
  }
}
