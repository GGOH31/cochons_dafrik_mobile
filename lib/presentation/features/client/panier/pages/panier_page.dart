import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';

class PanierPage extends StatelessWidget {
  final VoidCallback? onDiscoverTap;

  const PanierPage({super.key, this.onDiscoverTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          "Mon Panier",
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
                color: CdaColors.jaune.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.shoppingCart,
                size: 64,
                color: CdaColors.jaune,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Votre panier est vide",
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CdaColors.encre,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ajoutez des délicieux morceaux de porc pour commander !",
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
                "Faire mes achats",
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
