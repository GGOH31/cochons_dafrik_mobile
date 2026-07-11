import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/commande_vendeur/pages/commande_vendeur_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/gestions_products_categories_promotions_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/profil_vendeur/pages/profil_vendeur_page.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_commande_vendeur_common.dart';

class HomeVendeurPage extends StatefulWidget {
  const HomeVendeurPage({super.key});

  @override
  State<HomeVendeurPage> createState() => _HomeVendeurPageState();
}

class _HomeVendeurPageState extends State<HomeVendeurPage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (index) {
            setState(() {
              _currentTab = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: CdaColors.vertForet,
          unselectedItemColor: CdaColors.gris,
          selectedLabelStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.nunito(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.fileText),
              label: 'Commandes',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.package),
              label: 'Produits',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case 0:
        return _buildHomeTab();
      case 1:
        return CommandeVendeurPage(
          onViewAllOrders: () => setState(() => _currentTab = 1),
        );
      case 2:
        return const GestionsProductsCategoriesPromotionsPage();
      case 3:
        return const ProfilVendeurPage();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        // Main Layout Scroll View
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Green Header (fixed at top)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 44),
              decoration: const BoxDecoration(
                color: CdaColors.vertForet,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chez Tantie Porc • Yopougon",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Bonjour Tantie 🐷",
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 36,
                    ), // Spacing to clear the floating badge
                    // Solde Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E6C40), // Dark green solde card
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E6C40).withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SOLDE DISPONIBLE",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "184 500 F CFA",
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Stats and Action Sub-container
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "En séquestre",
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "23 300 F",
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ventes du jour",
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "12 cmd",
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Demande de retrait envoyée !",
                                        ),
                                        backgroundColor: CdaColors.vertForet,
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "Retirer →",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: CdaColors.jaune,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Info Grid Row
                    Row(
                      children: [
                        Expanded(child: _buildInfoCard("12", "Commandes")),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoCard("★ 4,8", "Note")),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoCard("-3%", "Commission")),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Section: Nouvelle commande
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nouvelle commande",
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CdaColors.encre,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _currentTab = 1),
                          child: Text(
                            "Tout voir",
                            style: GoogleFonts.nunito(
                              color: CdaColors.rouge,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CardCommandeVendeurCommon(
                      orderId: "#CDA-1043",
                      customerName: "Awa K.",
                      details: "2 × Porc braisé + attiéké",
                      commune: "Cocody",
                      price: "8 000 F",
                      isNew: true,
                      statusLabel: "NOUVELLE",
                      statusColor: const Color(0xFFD68000),
                      statusBg: const Color(0xFFFFF7EC),
                      onAccept: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Commande acceptée, début de cuisson !",
                            ),
                            backgroundColor: CdaColors.vertForet,
                          ),
                        );
                      },
                      onReject: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Commande refusée."),
                            backgroundColor: CdaColors.rouge,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Floating Badge Overlay ("Boutique ouverte")
        IgnorePointer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Opacity(
                    opacity: 0.0,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 44),
                      decoration: const BoxDecoration(
                        color: CdaColors.vertForet,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chez Tantie Porc • Yopougon",
                            style: GoogleFonts.nunito(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Bonjour Tantie 🐷",
                            style: GoogleFonts.fredoka(fontSize: 26),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: CdaColors.jaune,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: CdaColors.vertFonce.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00C853),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Boutique ouverte",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800,
                                color: CdaColors.encre,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CdaColors.ligne, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E6C40),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: CdaColors.gris,
            ),
          ),
        ],
      ),
    );
  }
}
