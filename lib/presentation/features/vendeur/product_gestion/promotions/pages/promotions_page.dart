import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_promotion_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/promotions/pages/promotion_form_page.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  final VendeurService _vendeurService = VendeurService();
  List<dynamic> _promotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final promos = await _vendeurService.getPromotions();
      setState(() {
        _promotions = promos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors du chargement des promotions : $e"),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CdaColors.vertForet),
              ),
            )
          : _promotions.isEmpty
              ? Center(
                  child: Text(
                    "Aucune promotion disponible",
                    style: TextStyle(
                      color: CdaColors.gris,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPromotions,
                  color: CdaColors.vertForet,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _promotions.length,
                    itemBuilder: (context, index) {
                      final promo = _promotions[index];
                      final title = promo['title'] ?? '';
                      final value = promo['value'] ?? 0;
                      final type = promo['promo_type'] ?? 'percentage';
                      final displayTitle = type == 'percentage'
                          ? "-$value% $title"
                          : "$value FCFA $title";

                      final startsAtStr = promo['starts_at'];
                      final endsAtStr = promo['ends_at'];
                      String datesInfo = "Permanent";

                      if (startsAtStr != null && endsAtStr != null) {
                        try {
                          final startsAt = DateTime.parse(startsAtStr).toLocal();
                          final endsAt = DateTime.parse(endsAtStr).toLocal();
                          datesInfo = "Du ${startsAt.day}/${startsAt.month} au ${endsAt.day}/${endsAt.month}";
                        } catch (_) {}
                      }

                      final productName = (promo['product'] != null && promo['product']['name'] != null)
                          ? promo['product']['name']
                          : 'Tous les produits';
                      final details = "$datesInfo • Produit : $productName";

                      final isActive = promo['is_active'] ?? true;
                      final statusLabel = isActive ? "PROMO ACTIVE" : "INACTIVE";
                      final statusColor = isActive ? CdaColors.encre : CdaColors.gris;
                      final statusBg = isActive ? const Color(0xFFFFC107) : const Color(0xFFE0E0E0);

                      return CardPromotionCommon(
                        title: displayTitle,
                        details: details,
                        statusLabel: statusLabel,
                        statusColor: statusColor,
                        statusBg: statusBg,
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PromotionFormPage(initialPromo: promo),
                            ),
                          );
                          if (result == true) {
                            _fetchPromotions();
                          }
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const PromotionFormPage(),
            ),
          );
          if (result == true) {
            _fetchPromotions();
          }
        },
        backgroundColor: CdaColors.vertForet,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}
