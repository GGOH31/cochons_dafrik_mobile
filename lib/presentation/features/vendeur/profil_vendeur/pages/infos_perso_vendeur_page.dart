import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';

class InfosPersoVendeurPage extends StatefulWidget {
  const InfosPersoVendeurPage({super.key});

  @override
  State<InfosPersoVendeurPage> createState() => _InfosPersoVendeurPageState();
}

class _InfosPersoVendeurPageState extends State<InfosPersoVendeurPage> {
  final VendeurService _vendeurService = VendeurService();
  Map<String, dynamic>? _personalInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPersonalInfo();
  }

  Future<void> _loadPersonalInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final info = await _vendeurService.getPersonalInfo();
      setState(() {
        _personalInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          "Informations Personnelles",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: CdaColors.encre,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CdaColors.encre),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(CdaColors.vertForet),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertTriangle,
                color: CdaColors.rouge,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                "Erreur de chargement",
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CdaColors.encre,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: CdaColors.gris,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPersonalInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CdaColors.vertForet,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(LucideIcons.refreshCw, size: 16, color: Colors.white),
                label: Text(
                  "Réessayer",
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

    if (_personalInfo == null) {
      return Center(
        child: Text(
          "Aucune donnée disponible",
          style: GoogleFonts.nunito(color: CdaColors.gris),
        ),
      );
    }

    final String fullName = _personalInfo!['full_name'] ?? 'Non spécifié';
    final String phone = _personalInfo!['phone'] ?? 'Non spécifié';
    final String email = _personalInfo!['email'] ?? 'Non spécifié';
    final String role = _personalInfo!['role'] ?? 'vendeur';
    final String status = _personalInfo!['status'] ?? 'pending';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: CdaColors.vertForet.withOpacity(0.1),
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'V',
                    style: GoogleFonts.fredoka(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.vertForet,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  fullName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CdaColors.encre,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detail Cards
          _buildInfoItem(
            icon: LucideIcons.user,
            title: "Nom complet",
            value: fullName,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: LucideIcons.phone,
            title: "Numéro de téléphone",
            value: phone,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: LucideIcons.mail,
            title: "Adresse e-mail",
            value: email,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: LucideIcons.shield,
            title: "Rôle",
            value: role.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CdaColors.vertForet.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: CdaColors.vertForet, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: CdaColors.gris,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: CdaColors.encre,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'verified':
      case 'approved':
        return CdaColors.vertForet;
      case 'pending':
        return CdaColors.jaune;
      case 'suspended':
      case 'blocked':
        return CdaColors.rouge;
      default:
        return CdaColors.gris;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'verified':
      case 'approved':
        return "Compte Actif";
      case 'pending':
        return "En attente de validation";
      case 'suspended':
      case 'blocked':
        return "Compte Suspendu";
      default:
        return status.toUpperCase();
    }
  }
}