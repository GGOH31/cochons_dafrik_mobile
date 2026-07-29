import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_commande_vendeur_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/appBar_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';

import 'package:cochons_dafrik_mobile/presentation/features/vendeur/commande_vendeur/pages/commande_vendeur_detail_page.dart';

class CommandeVendeurPage extends StatefulWidget {
  final VoidCallback? onViewAllOrders;

  const CommandeVendeurPage({super.key, this.onViewAllOrders});

  @override
  State<CommandeVendeurPage> createState() => _CommandeVendeurPageState();
}

class _CommandeVendeurPageState extends State<CommandeVendeurPage> {
  final VendeurService _vendeurService = VendeurService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _orders = [];
  String? _selectedStatusFilter; // null = tout

  final List<Map<String, String?>> _filters = [
    {'label': 'Toutes', 'status': null},
    {'label': 'Nouvelles', 'status': 'paid'},
    {'label': 'En préparation', 'status': 'preparing'},
    {'label': 'En route', 'status': 'delivering'},
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
      final orders = await _vendeurService.getOrders(
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

  Future<void> _acceptOrder(String orderId) async {
    try {
      await _vendeurService.acceptOrder(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Commande acceptée avec succès."),
            backgroundColor: CdaColors.vertForet,
          ),
        );
        _fetchOrders();
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
            content: Text("Commande refusée et client remboursé."),
            backgroundColor: CdaColors.rouge,
          ),
        );
        _fetchOrders();
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
        return {
          'label': 'EN ATTENTE PAYE',
          'color': const Color(0xFFD68000),
          'bg': const Color(0xFFFFF7EC),
        };
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
      case 'refused':
      case 'cancelled':
        return {
          'label': 'REFUSÉE',
          'color': const Color(0xFFD32F2F),
          'bg': const Color(0xFFFFEBEE),
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
      final name = item['product_name'] ?? item['dish']?['name'] ?? 'Article';
      final qty = item['quantity'] ?? 1;
      parts.add("${qty}× $name");
    }
    return parts.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: const CdaAppBar(
        title: "Mes Commandes Reçues",
        showBackButton: false,
        backgroundColor: CdaColors.vertFonce,
        foregroundColor: CdaColors.creme,
      ),
      body: Column(
        children: [
          // Filter Chips
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: CdaColors.gris.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  "Aucune commande trouvée",
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CdaColors.encre,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Les commandes reçues s'afficheront ici.",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: CdaColors.gris,
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
        final orderId = "#${order['reference'] ?? order['id'] ?? 'CDA'}";
        final buyer = order['buyer'] as Map<String, dynamic>?;
        final customerName = buyer?['full_name'] ?? 'Client';
        final details = _formatItemsDetails(order['items']);
        final address = order['address'] as Map<String, dynamic>?;
        final commune =
            address?['commune'] ?? order['restaurant']?['commune'] ?? 'Abidjan';
        final price = "${order['total_fcfa'] ?? 0} F";

        final String status = order['status'] ?? '';
        final isNew = status == 'paid' || status == 'pending_payment';
        final statusCfg = _getStatusConfig(status);

        return CardCommandeVendeurCommon(
          orderId: orderId,
          customerName: customerName,
          details: details,
          commune: commune,
          price: price,
          isNew: isNew,
          statusLabel: statusCfg['label'],
          statusColor: statusCfg['color'],
          statusBg: statusCfg['bg'],
          onAccept: () => _acceptOrder(order['id'].toString()),
          onReject: () => _refuseOrder(order['id'].toString()),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommandeVendeurDetailPage(
                  orderId: order['id'].toString(),
                  initialOrder: order,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
