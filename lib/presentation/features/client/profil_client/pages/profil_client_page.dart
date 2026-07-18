import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/auth/domains/services/auth_service.dart';
import 'client_adress_page.dart';
import 'infos_client_page.dart';

class ProfilClientPage extends StatefulWidget {
  const ProfilClientPage({super.key});

  @override
  State<ProfilClientPage> createState() => _ProfilClientPageState();
}

class _ProfilClientPageState extends State<ProfilClientPage> {
  final AuthService _authService = AuthService();
  String _userName = 'Client';
  String _userPhone = '';
  String _defaultAddressCommune = '';

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
        setState(() {
          if (user['full_name'] != null && user['full_name'].toString().trim().isNotEmpty) {
            _userName = user['full_name'].toString();
          }
          if (user['phone'] != null) {
            _userPhone = user['phone'].toString();
          }
          
          final addresses = user['addresses'] as List<dynamic>?;
          if (addresses != null && addresses.isNotEmpty) {
            final defaultAddress = addresses.firstWhere(
              (addr) => addr['is_default'] == true || addr['is_default'] == 1,
              orElse: () => addresses.first,
            );
            _defaultAddressCommune = defaultAddress['commune'] ?? defaultAddress['details'] ?? '';
          } else {
            _defaultAddressCommune = '';
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
              // Avatar & User info
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: CdaColors.rose,
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'C',
                        style: GoogleFonts.fredoka(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: CdaColors.rouge,
                        ),
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
                    if (_userPhone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _userPhone,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: CdaColors.gris,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Account options list
              _buildProfileOption(
                icon: LucideIcons.mapPin,
                title: "Mes Adresses de livraison",
                subtitle: _defaultAddressCommune.isNotEmpty ? _defaultAddressCommune : "Ajouter vos adresses de livraison",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ClientAdressPage()),
                  ).then((value) {
                    _loadUserData();
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildProfileOption(
                icon: LucideIcons.user,
                title: "Informations personnelles",
                subtitle: "Nom, téléphone, email",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InfosClientPage()),
                  ).then((value) {
                    _loadUserData();
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildProfileOption(
                icon: LucideIcons.history,
                title: "Historique de commande",
                subtitle: "Voir vos anciens achats",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Historique de commande à venir")),
                  );
                },
              ),
              const SizedBox(height: 36),

              // Log out button
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

  Widget _buildProfileOption({
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
