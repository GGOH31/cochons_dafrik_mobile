import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/client_service.dart';

class CommandeClientDetailPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic>? initialOrder;

  const CommandeClientDetailPage({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<CommandeClientDetailPage> createState() =>
      _CommandeClientDetailPageState();
}

class _CommandeClientDetailPageState extends State<CommandeClientDetailPage> {
  final ClientService _clientService = ClientService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _order;

  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrder != null) {
      _order = widget.initialOrder;
      _isLoading = false;
    }
    _fetchOrderDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrderDetails() async {
    if (_order == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final data = await _clientService.getOrderDetails(widget.orderId);
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

  Future<void> _confirmReception() async {
    try {
      await _clientService.confirmReception(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Réception confirmée et paiement libéré. Merci !"),
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

  Future<void> _submitReview() async {
    if (_rating < 1 || _rating > 5) return;

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final data = {
        'rating': _rating,
        if (_commentController.text.trim().isNotEmpty)
          'comment': _commentController.text.trim(),
      };
      await _clientService.submitReview(widget.orderId, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Avis envoyé avec succès ! Merci."),
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
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingReview = false;
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
          'step': 0,
        };
      case 'paid':
        return {
          'label': 'Payée / En attente d\'acceptation',
          'color': const Color(0xFFD68000),
          'bg': const Color(0xFFFFF7EC),
          'step': 1,
        };
      case 'accepted':
        return {
          'label': 'Acceptée par le vendeur',
          'color': const Color(0xFF1976D2),
          'bg': const Color(0xFFE3F2FD),
          'step': 2,
        };
      case 'preparing':
        return {
          'label': 'En préparation / Cuisson',
          'color': const Color(0xFF1976D2),
          'bg': const Color(0xFFE3F2FD),
          'step': 3,
        };
      case 'delivering':
        return {
          'label': 'En cours de livraison',
          'color': const Color(0xFF2E7D32),
          'bg': const Color(0xFFE8F5E9),
          'step': 4,
        };
      case 'delivered':
      case 'completed':
        return {
          'label': 'Livrée',
          'color': const Color(0xFF2E7D32),
          'bg': const Color(0xFFE8F5E9),
          'step': 5,
        };
      case 'refused':
        return {
          'label': 'Refusée & Remboursée',
          'color': const Color(0xFFD32F2F),
          'bg': const Color(0xFFFFEBEE),
          'step': -1,
        };
      case 'cancelled':
        return {
          'label': 'Annulée',
          'color': const Color(0xFFD32F2F),
          'bg': const Color(0xFFFFEBEE),
          'step': -1,
        };
      default:
        return {
          'label': status ?? 'En traitement',
          'color': const Color(0xFF1976D2),
          'bg': const Color(0xFFE3F2FD),
          'step': 1,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          _order != null
              ? "#${_order!['reference'] ?? 'Détails'}"
              : "Détails Commande",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: CdaColors.encre,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: CdaColors.encre),
          onPressed: () => Navigator.pop(context),
        ),
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
            ElevatedButton(
              onPressed: _fetchOrderDetails,
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
      );
    }

    final order = _order!;
    final reference = "#${order['reference'] ?? order['id'] ?? ''}";
    final status = order['status'] ?? '';
    final statusCfg = _getStatusConfig(status);

    final restaurant = order['restaurant'] as Map<String, dynamic>?;
    final restaurantName = restaurant?['name'] ?? 'Restaurant';

    final address = order['address'] as Map<String, dynamic>?;
    final commune = address?['commune'] ?? restaurant?['commune'] ?? 'Abidjan';
    final detailsAddress = address?['details'] ?? 'Livraison à domicile';

    final items = (order['items'] as List<dynamic>?) ?? [];
    final subtotal = order['subtotal_fcfa'] ?? 0;
    final delivery = order['delivery_fcfa'] ?? 0;
    final total = order['total_fcfa'] ?? 0;

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        reference,
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CdaColors.encre,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
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
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusCfg['color'],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Restaurant : $restaurantName",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CdaColors.vertForet,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Suivi de la commande (Progression Timeline)
          _buildCardTitle("Suivi de la commande"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CdaColors.ligne),
            ),
            child: Column(
              children: [
                _buildTimelineStep(1, "Payée", statusCfg['step'] >= 1),
                _buildTimelineLine(statusCfg['step'] >= 2),
                _buildTimelineStep(
                  2,
                  "Acceptée par la restaurant",
                  statusCfg['step'] >= 2,
                ),
                _buildTimelineLine(statusCfg['step'] >= 3),
                _buildTimelineStep(3, "En préparation", statusCfg['step'] >= 3),
                _buildTimelineLine(statusCfg['step'] >= 4),
                _buildTimelineStep(4, "En livraison", statusCfg['step'] >= 4),
                _buildTimelineLine(statusCfg['step'] >= 5),
                _buildTimelineStep(5, "Livrée", statusCfg['step'] >= 5),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Adresse de livraison
          _buildCardTitle("Livraison"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CdaColors.ligne),
            ),
            child: Column(
              children: [
                _buildDetailRow("Commune", commune),
                const Divider(height: 16, color: CdaColors.ligne),
                _buildDetailRow("Adresse", detailsAddress),
                if (order['delivery_code'] != null) ...[
                  const Divider(height: 16, color: CdaColors.ligne),
                  _buildDetailRow(
                    "Code de livraison",
                    order['delivery_code'],
                    isBold: true,
                    color: CdaColors.vertForet,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Articles
          _buildCardTitle("Articles (${items.length})"),
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
                          "${items[i]['quantity'] ?? 1}× ${items[i]['dish_name'] ?? items[i]['dish']?['name'] ?? 'Dish'}",
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

          // Total
          _buildCardTitle("Paiement"),
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
                  "Total réglé",
                  "$total FCFA",
                  isBold: true,
                  color: CdaColors.vertForet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions client (ex: confirmer réception si livrée)
          if (status == 'delivered' || status == 'delivering') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmReception,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CdaColors.vertForet,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Confirmer la réception de la commande",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if ((status == 'delivered' || status == 'completed') &&
              order['review'] == null) ...[
            _buildReviewForm(),
            const SizedBox(height: 24),
          ],
          if (order['review'] != null) ...[
            _buildReviewDisplay(order['review']),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewDisplay(Map<String, dynamic> review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardTitle("Votre avis"),
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
                children: List.generate(5, (index) {
                  return Icon(
                    index < (review['rating'] ?? 5)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  );
                }),
              ),
              if (review['comment'] != null &&
                  review['comment'].isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  review['comment'],
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: CdaColors.encre,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardTitle("Laisser un avis"),
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
              Text(
                "Notez votre expérience avec le restaurant :",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CdaColors.encre,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Laissez un commentaire (optionnel)...",
                  hintStyle: GoogleFonts.nunito(color: CdaColors.gris),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: CdaColors.ligne),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: CdaColors.vertForet),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmittingReview ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CdaColors.vertForet,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmittingReview
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Envoyer mon avis",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildTimelineStep(int stepNum, String title, bool isCompleted) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? CdaColors.vertForet : CdaColors.ligne,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle,
            size: 14,
            color: isCompleted ? Colors.white : CdaColors.gris,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
              color: isCompleted ? CdaColors.encre : CdaColors.gris,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 2, bottom: 2),
      alignment: Alignment.centerLeft,
      height: 16,
      width: 2,
      color: isCompleted ? CdaColors.vertForet : CdaColors.ligne,
    );
  }
}
