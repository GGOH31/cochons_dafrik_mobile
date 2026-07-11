import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/domains/services/auth_service.dart';

class ProfilVendeurPage extends StatelessWidget {
  const ProfilVendeurPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: CdaColors.creme,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Vendor Info Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: CdaColors.vertForet.withOpacity(0.1),
                      child: Text(
                        "🐷",
                        style: GoogleFonts.fredoka(
                          fontSize: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Chez Tantie Porc",
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CdaColors.encre,
                      ),
                    ),
                    Text(
                      "Yopougon, Abidjan",
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: CdaColors.gris,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Options
              _buildOption(
                icon: LucideIcons.store,
                title: "Paramètres de la Boutique",
                subtitle: "Nom, horaires, statut ouvert/fermé",
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: LucideIcons.wallet,
                title: "Informations de Paiement",
                subtitle: "Mobile Money Configuré",
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: LucideIcons.helpCircle,
                title: "Aide & Support",
                subtitle: "FAQ, nous contacter",
                onTap: () {},
              ),
              const SizedBox(height: 36),

              // Logout Button
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: CdaColors.rouge, width: 1),
                ),
                leading: const Icon(LucideIcons.logOut, color: CdaColors.rouge),
                title: Text(
                  "Se déconnecter",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: CdaColors.rouge,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: CdaColors.rouge,
                ),
                onTap: () {
                  authService.logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: CdaColors.vertForet),
        title: Text(
          title,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: CdaColors.encre,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.nunito(color: CdaColors.gris, fontSize: 13),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: CdaColors.gris,
        ),
        onTap: onTap,
      ),
    );
  }
}
