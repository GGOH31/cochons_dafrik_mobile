// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/themes/app_color.dart';

/// Affiche un SnackBar personnalisé et élégant pour Cochons d'Afrik.
/// Il efface les précédents SnackBars en cours avant d'afficher le nouveau.
void showCdaSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 4),
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  
  // Supprime immédiatement tout SnackBar actuellement affiché
  scaffoldMessenger.clearSnackBars();

  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? CdaColors.rouge : CdaColors.vertForet,
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      duration: duration,
    ),
  );
}
