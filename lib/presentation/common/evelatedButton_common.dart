// ignore_for_file: file_names
import 'package:flutter/material.dart';

/// Un bouton élevé personnalisé réutilisable pour Cochons d'Afrik.
/// Il prend en charge un état de chargement ([isLoading]) et des icônes optionnelles.
class CdaElevatedButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? icon;
  final double height;
  final double? width;

  const CdaElevatedButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.height = 52.0,
    this.width,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Si nous avons une icône, nous utilisons ElevatedButton.icon
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: Size(width ?? double.infinity, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );

    if (isLoading) {
      return SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: null, // Désactive le bouton pendant le chargement
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                foregroundColor ?? theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      );
    }

    if (icon != null) {
      return SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: ElevatedButton.icon(
          style: buttonStyle,
          onPressed: onPressed,
          icon: icon!,
          label: child ?? Text(text ?? ''),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: onPressed,
        child: child ?? Text(text ?? ''),
      ),
    );
  }
}
