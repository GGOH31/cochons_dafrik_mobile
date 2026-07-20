import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/client_service.dart';

import 'package:cochons_dafrik_mobile/presentation/features/client/commande_client/pages/commande_client_detail_page.dart';

class CommandeClientPage extends StatefulWidget {
  final VoidCallback? onDiscoverTap;

  const CommandeClientPage({super.key, this.onDiscoverTap});

  @override
  State<CommandeClientPage> createState() => _CommandeClientPageState();
}

class _CommandeClientPageState extends State<CommandeClientPage> {
  final ClientService _clientService = ClientService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _orders = [];
  String? _selectedStatusFilter;

  final List<Map<String, String?>> _filters = [
    {'label': 'Toutes', 'status': null},
    {'label': 'En cours', 'status': 'paid'},
    {'label': 'En préparation', 'status': 'preparing'},
    {'label': 'En livraison', 'status': 'delivering'},
    {'label': 'Livrées', 'status': 'delivered'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _clientService.getOrders(
        status: _selectedStatusFilter,
      );
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getStatusConfig(String? status) {
    switch (status) {
      case 'pending_payment':
        return {
          'label': 'En attente de paiement',
          'color': const Color(0xFFD68000),
          'bg': const Color(0xFFFFF7EC),
        };
      case 'paid':
        return {
          'label': 'Payée / En attente',
          'color': const Color(0xFFD68000),
          'bg': const Color(0xFFFFF7EC),
        };
      case 'accepted':
        return {
          'label': 'Acceptée',
          'color': const Color(0xFF1976D2),
          'bg': const Color(0xFFE3F2FD),
        };
      case 'preparing':
        return {
          'label': 'En préparation',
          'color': const Color(0xFF1976D2),
          'bg': const Color(0xFFE3F2FD),
        };
      case 'delivering':
        return {
          'label': 'En cours de livraison',
          'color': const Color(0xFF2E7D32),
          'bg': const Color(0xFFE8F5E9),
        };
      case 'delivered':
      case 'completed':
        return {
          'label': 'Livrée',
          'color': const Color(0xFF2E7D32),
          'bg': const Color(0xFFE8F5E9),
        };
      case 'refused':
        return {
          'label': 'Refusée & Remboursée',
          'color': const Color(0xFFD32F2F),
          'bg': const Color(0xFFFFEBEE),
        };
      case 'cancelled':
        return {
          'label': 'Annulée',
          'color': const Color(0xFFD32F2F),
          'bg': const Color(0xFFFFEBEE),
        };
      default:
        return {
          'label': status ?? 'En traitement',
          'color': const Color(0xFF1976D2),
          'bg': const Color(0xFFE3F2FD),
        };
    }
  }

  String _formatItems(dynamic items) {
    if (items == null || items is! List || items.isEmpty) {
      return "Commande de produits";
    }
    final List<String> parts = [];
    for (var item in items) {
      final name =
          item['product_name'] ?? item['product']?['name'] ?? 'Produit';
      final qty = item['quantity'] ?? 1;
      parts.add("${qty}× $name");
    }
    return parts.join(", ");
  }

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
      body: Column(
        children: [
          // Filters
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedStatusFilter == filter['status'];
                return ChoiceChip(
                  label: Text(
                    filter['label']!,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : CdaColors.encre,
                      fontSize: 13,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: CdaColors.vertForet,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? CdaColors.vertForet : CdaColors.ligne,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatusFilter = filter['status'];
                      });
                      _fetchOrders();
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchOrders,
              color: CdaColors.vertForet,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: CdaColors.vertForet),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: CdaColors.rouge,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.nunito(
                    color: CdaColors.gris,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchOrders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CdaColors.vertForet,
                  ),
                  child: const Text(
                    "Réessayer",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(
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
                  "Vos commandes apparaîtront ici.",
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: CdaColors.gris,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.onDiscoverTap != null)
                  ElevatedButton(
                    onPressed: widget.onDiscoverTap,
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
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20.0),
      itemCount: _orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = _orders[index] as Map<String, dynamic>;
        final shop = order['shop'] as Map<String, dynamic>?;
        final shopName = shop?['name'] ?? 'Boutique';
        final reference = "#${order['reference'] ?? order['id'] ?? ''}";
        final statusCfg = _getStatusConfig(order['status']);
        final itemsDetails = _formatItems(order['items']);
        final total = "${order['total_fcfa'] ?? 0} FCFA";

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommandeClientDetailPage(
                  orderId: order['id'].toString(),
                  initialOrder: order,
                ),
              ),
            );
          },
          child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CdaColors.ligne, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      shopName,
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: CdaColors.encre,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusCfg['bg'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusCfg['label'],
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusCfg['color'],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                reference,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: CdaColors.gris,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 20, color: CdaColors.ligne),
              Text(
                itemsDetails,
                style: GoogleFonts.nunito(fontSize: 14, color: CdaColors.encre),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total :",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: CdaColors.gris,
                    ),
                  ),
                  Text(
                    total,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.vertForet,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}
