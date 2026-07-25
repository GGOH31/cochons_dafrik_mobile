import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/profil_vendeur/pages/forms/form_update_boutique_page.dart';

class InfosBoutiquePage extends StatefulWidget {
  const InfosBoutiquePage({super.key});

  @override
  State<InfosBoutiquePage> createState() => _InfosBoutiquePageState();
}

class _InfosBoutiquePageState extends State<InfosBoutiquePage> {
  final VendeurService _vendeurService = VendeurService();
  Map<String, dynamic>? _shopData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadShopInfo();
  }

  Future<void> _loadShopInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final restaurant = await _vendeurService.getShopInfo();
      setState(() {
        _shopData = restaurant;
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
          "Ma Restaurant",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: CdaColors.encre,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CdaColors.encre),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_shopData != null)
            IconButton(
              icon: const Icon(LucideIcons.edit3, color: CdaColors.vertForet),
              onPressed: _navigateToEdit,
            ),
        ],
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
                onPressed: _loadShopInfo,
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

    if (_shopData == null) {
      return Center(
        child: Text(
          "Aucune restaurant trouvée",
          style: GoogleFonts.nunito(color: CdaColors.gris),
        ),
      );
    }

    final String name = _shopData!['name'] ?? 'Restaurant sans nom';
    final String description = _shopData!['description'] ?? 'Aucune description fournie.';
    final String commune = _shopData!['commune'] ?? 'Non spécifiée';
    final String address = _shopData!['address'] ?? 'Non spécifiée';
    final String? logoUrl = _shopData!['logo_url'];
    final double? latitude = _shopData!['latitude'];
    final double? longitude = _shopData!['longitude'];
    final int deliveryFee = _shopData!['delivery_fee_fcfa'] ?? 0;
    final int minOrder = _shopData!['min_order_fcfa'] ?? 0;
    final String deliveryZone = _shopData!['delivery_zone'] ?? 'Non spécifiée';
    final String status = _shopData!['status'] ?? 'pending';
    final bool isOpen = _shopData!['is_open'] ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Restaurant Card
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
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: CdaColors.vertForet.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CdaColors.ligne, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: logoUrl != null && logoUrl.isNotEmpty
                        ? Image.network(
                            logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Text("🏪", style: TextStyle(fontSize: 40))),
                          )
                        : const Center(child: Text("🏪", style: TextStyle(fontSize: 40))),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CdaColors.encre,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOpen
                            ? CdaColors.vertForet.withOpacity(0.1)
                            : CdaColors.rouge.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isOpen ? "Ouvert" : "Fermé",
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isOpen ? CdaColors.vertForet : CdaColors.rouge,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            "Détails de la Restaurant",
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CdaColors.encre,
            ),
          ),
          const SizedBox(height: 12),

          _buildDetailItem(
            icon: LucideIcons.alignLeft,
            title: "Description",
            value: description,
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: LucideIcons.mapPin,
            title: "Commune & Adresse",
            value: "$commune, $address",
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: LucideIcons.truck,
            title: "Frais de livraison",
            value: "$deliveryFee FCFA",
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: LucideIcons.shoppingBag,
            title: "Minimum de commande",
            value: "$minOrder FCFA",
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: LucideIcons.map,
            title: "Zone de livraison",
            value: deliveryZone,
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: LucideIcons.compass,
            title: "Coordonnées géographiques",
            value: latitude != null && longitude != null
                ? "Lat: $latitude, Lon: $longitude"
                : "Non renseignées",
          ),
          const SizedBox(height: 36),

          // Edit Button at the bottom
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _navigateToEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: CdaColors.vertForet,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(LucideIcons.edit3, color: Colors.white),
              label: Text(
                "Modifier la Restaurant",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CdaColors.vertForet.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: CdaColors.vertForet, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: CdaColors.gris,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: CdaColors.encre,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormUpdateBoutiquePage(restaurant: _shopData),
      ),
    ).then((value) {
      if (value == true) {
        _loadShopInfo();
      }
    });
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
        return "Approuvée";
      case 'pending':
        return "En attente";
      case 'suspended':
      case 'blocked':
        return "Bloquée";
      default:
        return status.toUpperCase();
    }
  }
}
