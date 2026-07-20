import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/commande_vendeur/pages/commande_vendeur_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/commande_vendeur/pages/commande_vendeur_detail_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/gestions_products_categories_promotions_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/profil_vendeur/pages/profil_vendeur_page.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_commande_vendeur_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';

class HomeVendeurPage extends StatefulWidget {
  const HomeVendeurPage({super.key});

  @override
  State<HomeVendeurPage> createState() => _HomeVendeurPageState();
}

class _HomeVendeurPageState extends State<HomeVendeurPage> {
  final VendeurService _vendeurService = VendeurService();
  int _currentTab = 0;
  String _userName = 'Vendeur';

  bool _isLoadingDashboard = true;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchDashboard();
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        final Map<String, dynamic> user = jsonDecode(userString);
        final fullName = user['full_name'];
        if (fullName != null && fullName.toString().trim().isNotEmpty) {
          setState(() {
            _userName = fullName.toString();
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoadingDashboard = true;
      _errorMessage = null;
    });

    try {
      final data = await _vendeurService.getDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          if (data['vendor']?['full_name'] != null) {
            _userName = data['vendor']['full_name'];
          }
          _isLoadingDashboard = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingDashboard = false;
        });
      }
    }
  }

  Future<void> _acceptOrder(String orderId) async {
    try {
      await _vendeurService.acceptOrder(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Commande acceptée, début de cuisson !"),
            backgroundColor: CdaColors.vertForet,
          ),
        );
        _fetchDashboard();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    }
  }

  Future<void> _refuseOrder(String orderId) async {
    try {
      await _vendeurService.refuseOrder(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Commande refusée."),
            backgroundColor: CdaColors.rouge,
          ),
        );
        _fetchDashboard();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _getStatusConfig(String? status) {
    switch (status) {
      case 'pending_payment':
      case 'paid':
        return {
          'label': 'NOUVELLE',
          'color': const Color(0xFFD68000),
          'bg': const Color(0xFFFFF7EC),
        };
      case 'accepted':
        return {
          'label': 'ACCEPTÉE',
          'color': const Color(0xFF1976D2),
          'bg': const Color(0xFFE3F2FD),
        };
      case 'preparing':
        return {
          'label': 'EN CUISSON',
          'color': const Color(0xFF1976D2),
          'bg': const Color(0xFFE3F2FD),
        };
      case 'delivering':
        return {
          'label': 'EN ROUTE',
          'color': const Color(0xFF2E7D32),
          'bg': const Color(0xFFE8F5E9),
        };
      case 'delivered':
      case 'completed':
        return {
          'label': 'LIVRÉE',
          'color': const Color(0xFF2E7D32),
          'bg': const Color(0xFFE8F5E9),
        };
      default:
        return {
          'label': (status ?? 'EN COURS').toUpperCase(),
          'color': const Color(0xFF1976D2),
          'bg': const Color(0xFFE3F2FD),
        };
    }
  }

  String _formatItemsDetails(dynamic items) {
    if (items == null || items is! List || items.isEmpty) {
      return "Articles de la commande";
    }
    final List<String> parts = [];
    for (var item in items) {
      final name =
          item['product_name'] ?? item['product']?['name'] ?? 'Article';
      final qty = item['quantity'] ?? 1;
      parts.add("${qty}× $name");
    }
    return parts.join(", ");
  }

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
            if (index == 0) {
              _fetchDashboard();
            }
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
    final shop = _dashboardData?['shop'] as Map<String, dynamic>?;
    final wallet = _dashboardData?['wallet'] as Map<String, dynamic>?;
    final stats = _dashboardData?['stats'] as Map<String, dynamic>?;
    final latestOrder =
        _dashboardData?['latest_order'] as Map<String, dynamic>?;

    final shopName = shop?['name'] ?? 'Boutique Vendeur';
    final commune = shop?['commune'] ?? 'Abidjan';
    final isOpen = shop?['is_open'] ?? true;

    final balanceFcfa = wallet?['balance_fcfa'] ?? 0;
    final escrowFcfa = wallet?['escrow_fcfa'] ?? 0;
    final todayOrdersCount = stats?['today_orders_count'] ?? 0;
    final totalOrdersCount = stats?['total_orders_count'] ?? 0;
    final ratingAvg = stats?['rating_avg'] ?? 5.0;
    final commissionPct = stats?['commission_pct'] ?? 10.0;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Green Header
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
                      "$shopName • $commune",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Bonjour $_userName 🐷",
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
              child: RefreshIndicator(
                onRefresh: _fetchDashboard,
                color: CdaColors.vertForet,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),
                      // Solde Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E6C40),
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
                              _isLoadingDashboard
                                  ? "... F CFA"
                                  : "$balanceFcfa F CFA",
                              style: GoogleFonts.nunito(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        "$escrowFcfa F",
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        "$todayOrdersCount cmd",
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                          Expanded(
                            child: _buildInfoCard(
                              "$totalOrdersCount",
                              "Commandes",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard("★ $ratingAvg", "Note"),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              "-$commissionPct%",
                              "Commission",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Section: Nouvelle commande
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Dernière commande",
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

                      if (_isLoadingDashboard)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: CdaColors.vertForet,
                            ),
                          ),
                        )
                      else if (latestOrder != null) ...[
                        Builder(
                          builder: (context) {
                            final orderId =
                                "#${latestOrder['reference'] ?? latestOrder['id'] ?? 'CDA'}";
                            final buyer =
                                latestOrder['buyer'] as Map<String, dynamic>?;
                            final customerName =
                                buyer?['full_name'] ?? 'Client';
                            final details = _formatItemsDetails(
                              latestOrder['items'],
                            );
                            final address =
                                latestOrder['address'] as Map<String, dynamic>?;
                            final orderCommune = address?['commune'] ?? commune;
                            final price = "${latestOrder['total_fcfa'] ?? 0} F";

                            final String status = latestOrder['status'] ?? '';
                            final isNew =
                                status == 'paid' || status == 'pending_payment';
                            final statusCfg = _getStatusConfig(status);

                            return CardCommandeVendeurCommon(
                              orderId: orderId,
                              customerName: customerName,
                              details: details,
                              commune: orderCommune,
                              price: price,
                              isNew: isNew,
                              statusLabel: statusCfg['label'],
                              statusColor: statusCfg['color'],
                              statusBg: statusCfg['bg'],
                              onAccept: () =>
                                  _acceptOrder(latestOrder['id'].toString()),
                              onReject: () =>
                                  _refuseOrder(latestOrder['id'].toString()),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CommandeVendeurDetailPage(
                                          orderId: latestOrder['id'].toString(),
                                          initialOrder: latestOrder,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ] else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: CdaColors.ligne),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.packageCheck,
                                size: 40,
                                color: CdaColors.gris.withOpacity(0.6),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Aucune nouvelle commande",
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CdaColors.encre,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Les prochaines commandes apparaîtront ici.",
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: CdaColors.gris,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
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
                            "$shopName • $commune",
                            style: GoogleFonts.nunito(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Bonjour $_userName 🐷",
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
                        width: 300,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? CdaColors.jaune
                              : const Color(0xFFFFEBEE),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isOpen
                                    ? const Color(0xFF00C853)
                                    : const Color(0xFFD32F2F),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isOpen ? "Boutique ouverte" : "Boutique fermée",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800,
                                color: isOpen
                                    ? CdaColors.encre
                                    : const Color(0xFFD32F2F),
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
