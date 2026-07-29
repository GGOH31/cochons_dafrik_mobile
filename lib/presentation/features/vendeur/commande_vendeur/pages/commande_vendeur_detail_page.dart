import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/appBar_common.dart';

class CommandeVendeurDetailPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic>? initialOrder;

  const CommandeVendeurDetailPage({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<CommandeVendeurDetailPage> createState() =>
      _CommandeVendeurDetailPageState();
}

class _CommandeVendeurDetailPageState extends State<CommandeVendeurDetailPage> {
  final VendeurService _vendeurService = VendeurService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrder != null) {
      _order = widget.initialOrder;
      _isLoading = false;
    }
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    if (_order == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final data = await _vendeurService.getOrderDetails(widget.orderId);
      if (mounted) {
        setState(() {
          _order = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && _order == null) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptOrder() async {
    try {
      await _vendeurService.acceptOrder(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Commande acceptée avec succès."),
            backgroundColor: CdaColors.vertForet,
          ),
        );
        _fetchOrderDetails();
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

  Future<void> _refuseOrder() async {
    try {
      await _vendeurService.refuseOrder(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Commande refusée et client remboursé."),
            backgroundColor: CdaColors.rouge,
          ),
        );
        _fetchOrderDetails();
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

  Future<void> _updateStatus(String newStatus) async {
    try {
      await _vendeurService.updateOrderStatus(widget.orderId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Statut de la commande mis à jour."),
            backgroundColor: CdaColors.vertForet,
          ),
        );
        _fetchOrderDetails();
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
          'label': 'En attente de paiement',
          'color': const Color(0xFFD68000),
          'bg': const Color(0xFFFFF7EC),
        };
      case 'paid':
        return {
          'label': 'Nouvelle Commande',
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
          'label': 'En préparation / Cuisson',
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
          'label': 'Refusée',
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
          'label': (status ?? 'EN COURS').toUpperCase(),
          'color': const Color(0xFF1976D2),
          'bg': const Color(0xFFE3F2FD),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: CdaAppBar(
        title: _order != null
            ? "#${_order!['reference'] ?? 'Détails'}"
            : "Détail Commande",
        showBackButton: true,
        backgroundColor: CdaColors.vertFonce,
        foregroundColor: CdaColors.creme,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _order == null) {
      return const Center(
        child: CircularProgressIndicator(color: CdaColors.vertForet),
      );
    }

    if (_errorMessage != null && _order == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: CdaColors.rouge),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: GoogleFonts.nunito(color: CdaColors.gris, fontSize: 14),
            ),
            const SizedBox(height: 16),
            CdaElevatedButton(
              onPressed: _fetchOrderDetails,
              backgroundColor: CdaColors.vertForet,
              foregroundColor: Colors.white,
              text: "Réessayer",
            ),
          ],
        ),
      );
    }

    final order = _order!;
    final reference = "#${order['reference'] ?? order['id'] ?? ''}";
    final status = order['status'] ?? '';
    final statusCfg = _getStatusConfig(status);

    final buyer = order['buyer'] as Map<String, dynamic>?;
    final buyerName = buyer?['full_name'] ?? 'Client inconnu';
    final buyerPhone = buyer?['phone'] ?? 'N/A';

    final address = order['address'] as Map<String, dynamic>?;
    final commune =
        address?['commune'] ??
        order['restaurant']?['commune'] ??
        'Non spécifiée';
    final detailsAddress = address?['details'] ?? 'Livraison standard';

    final items = (order['items'] as List<dynamic>?) ?? [];
    final subtotal = order['subtotal_fcfa'] ?? 0;
    final delivery = order['delivery_fcfa'] ?? 0;
    final total = order['total_fcfa'] ?? 0;
    final sellerNet = order['seller_net_fcfa'] ?? total;

    return RefreshIndicator(
      onRefresh: _fetchOrderDetails,
      color: CdaColors.vertForet,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CdaColors.ligne),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        reference,
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusCfg['color'],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Type : ${order['order_type'] == 'b2b' ? 'B2B (Vente en gros)' : 'B2C (Vente au détail)'}",
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: CdaColors.gris,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Client Info
          _buildCardTitle("Client & Delivery"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CdaColors.ligne),
            ),
            child: Column(
              children: [
                _buildDetailRow("Client", buyerName, isBold: true),
                const Divider(height: 16, color: CdaColors.ligne),
                _buildDetailRow("Téléphone", buyerPhone),
                const Divider(height: 16, color: CdaColors.ligne),
                _buildDetailRow("Commune", commune),
                const Divider(height: 16, color: CdaColors.ligne),
                _buildDetailRow("Adresse", detailsAddress),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Articles List
          _buildCardTitle("Articles commandés (${items.length})"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CdaColors.ligne),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(height: 16, color: CdaColors.ligne),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${items[i]['quantity'] ?? 1}× ${items[i]['dish_name'] ?? items[i]['dish']?['name'] ?? 'Article'}",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CdaColors.encre,
                          ),
                        ),
                      ),
                      Text(
                        "${items[i]['line_total_fcfa'] ?? 0} F",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CdaColors.vertForet,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Financial Summary
          _buildCardTitle("Récapitulatif Financier"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CdaColors.ligne),
            ),
            child: Column(
              children: [
                _buildDetailRow("Sous-total", "$subtotal FCFA"),
                const SizedBox(height: 8),
                _buildDetailRow("Frais de livraison", "$delivery FCFA"),
                const Divider(height: 16, color: CdaColors.ligne),
                _buildDetailRow(
                  "Montant Total",
                  "$total FCFA",
                  isBold: true,
                  color: CdaColors.vertForet,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  "Net Vendeur",
                  "$sellerNet FCFA",
                  color: CdaColors.encre,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          if (status == 'paid' || status == 'pending_payment') ...[
            Row(
              children: [
                Expanded(
                  child: CdaElevatedButton(
                    onPressed: _acceptOrder,
                    backgroundColor: const Color(0xFF1E6C40),
                    child: Text(
                      "Accepter & Cuire",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CdaElevatedButton(
                    onPressed: _refuseOrder,
                    backgroundColor: const Color(0xFFFCEBEB),
                    child: Text(
                      "Refuser",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: CdaColors.rouge,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (status == 'accepted') ...[
            SizedBox(
              width: double.infinity,
              child: CdaElevatedButton(
                onPressed: () => _updateStatus('preparing'),
                backgroundColor: const Color(0xFFD68000),
                child: Text(
                  "Passer en préparation / Cuisson",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ] else if (status == 'preparing') ...[
            SizedBox(
              width: double.infinity,
              child: CdaElevatedButton(
                onPressed: () => _updateStatus('delivering'),
                backgroundColor: const Color(0xFF1976D2),
                child: Text(
                  "Lancer la livraison (En route)",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ] else if (status == 'delivering') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF16A34A)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Le livreur est en route. En attente de confirmation de réception par le client.",
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF166534),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCardTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: CdaColors.encre,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 14, color: CdaColors.gris),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? CdaColors.encre,
            ),
          ),
        ),
      ],
    );
  }
}
