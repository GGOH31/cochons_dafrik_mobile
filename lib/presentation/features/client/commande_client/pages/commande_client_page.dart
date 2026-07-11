import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';

class CommandeClientPage extends StatelessWidget {
  final VoidCallback? onDiscoverTap;

  const CommandeClientPage({super.key, this.onDiscoverTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          "Mes Commandes",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: CdaColors.encre,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CdaColors.vertForet.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.fileText,
                size: 64,
                color: CdaColors.vertForet,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Aucune commande active",
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CdaColors.encre,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Vos commandes en cours apparaîtront ici.",
              style: GoogleFonts.nunito(fontSize: 15, color: CdaColors.gris),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onDiscoverTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: CdaColors.vertForet,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Découvrir les boutiques",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
