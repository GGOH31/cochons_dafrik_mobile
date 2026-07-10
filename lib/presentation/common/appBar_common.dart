// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';

/// Un AppBar personnalisé et réutilisable pour Cochons d'Afrik.
/// Il prend en charge l'affichage ou non d'un bouton de retour,
/// un titre personnalisé et des boutons d'actions supplémentaires.
class CdaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;

  const CdaAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = CdaColors.encre,
    this.elevation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      foregroundColor: foregroundColor,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 40),
              onPressed: onBackPressed ?? () => Navigator.maybePop(context),
            )
          : null,
      title:
          titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor,
                  ),
                )
              : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
