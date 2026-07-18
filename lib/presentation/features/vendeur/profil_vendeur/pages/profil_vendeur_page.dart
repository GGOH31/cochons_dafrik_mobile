import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/domains/services/auth_service.dart';

class ProfilVendeurPage extends StatefulWidget {
  const ProfilVendeurPage({super.key});

  @override
  State<ProfilVendeurPage> createState() => _ProfilVendeurPageState();
}

class _ProfilVendeurPageState extends State<ProfilVendeurPage> {
  final AuthService _authService = AuthService();
  String _userName = 'Vendeur';
  String _shopName = '';
  String _shopLocation = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        final Map<String, dynamic> user = jsonDecode(userString);
        final fullName = user['full_name'];
        final shop = user['shop'];
        setState(() {
          if (fullName != null && fullName.toString().trim().isNotEmpty) {
            _userName = fullName.toString();
          }
          if (shop != null) {
            _shopName = shop['name']?.toString() ?? '';
            final commune = shop['commune']?.toString();
            final address = shop['address']?.toString();
            if (commune != null &&
                address != null &&
                commune.isNotEmpty &&
                address.isNotEmpty) {
              _shopLocation = "$commune, $address";
            } else if (commune != null && commune.isNotEmpty) {
              _shopLocation = commune;
            } else if (address != null && address.isNotEmpty) {
              _shopLocation = address;
            }
          }
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        _userName[0].toUpperCase(),
                        style: GoogleFonts.fredoka(fontSize: 48),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CdaColors.encre,
                      ),
                    ),
                    if (_shopName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _shopName,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CdaColors.vertForet,
                        ),
                      ),
                    ],
                    Text(
                      _shopLocation.isNotEmpty
                          ? _shopLocation
                          : "Yopougon, Abidjan",
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
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.infosBoutique).then((
                    _,
                  ) {
                    _loadUserData();
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: LucideIcons.user,
                title: "Informations Personnelles",
                subtitle: "Nom, téléphone, email",
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.infosPersonnelles,
                  ).then((_) {
                    _loadUserData();
                  });
                },
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
                  _authService.logout();
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
