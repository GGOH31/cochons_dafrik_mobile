import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_produit_vendeur_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/accompaniments/pages/accompaniment_form_page.dart';

class AccompanimentPage extends StatefulWidget {
  const AccompanimentPage({super.key});

  @override
  State<AccompanimentPage> createState() => _AccompanimentPageState();
}

class _AccompanimentPageState extends State<AccompanimentPage> {
  final VendeurService _vendeurService = VendeurService();
  List<dynamic> _accompaniments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccompaniments();
  }

  Future<void> _fetchAccompaniments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final accompaniments = await _vendeurService.getAccompaniments();
      setState(() {
        _accompaniments = accompaniments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors du chargement des accompagnements : $e"),
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
          : _accompaniments.isEmpty
              ? Center(
                  child: Text(
                    "Aucun accompagnement disponible",
                    style: TextStyle(
                      color: CdaColors.gris,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAccompaniments,
                  color: CdaColors.vertForet,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _accompaniments.length,
                    itemBuilder: (context, index) {
                      final acc = _accompaniments[index];
                      final price = acc['prix_unit'] ?? 0;
                      final productName = (acc['dish'] != null && acc['dish']['name'] != null)
                          ? acc['dish']['name']
                          : 'Dish inconnu';

                      return CardProduitVendeurCommon(
                        emoji: '🍱',
                        photoUrl: acc["photo_url"],
                        name: acc["name"] ?? "",
                        statusLabel: "$price FCFA",
                        statusColor: CdaColors.vertForet,
                        statusBg: CdaColors.creme,
                        details: "Associé à : $productName",
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccompanimentFormPage(
                                initialAccompaniment: acc,
                              ),
                            ),
                          );
                          if (result == true) {
                            _fetchAccompaniments();
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
              builder: (context) => const AccompanimentFormPage(),
            ),
          );
          if (result == true) {
            _fetchAccompaniments();
          }
        },
        backgroundColor: CdaColors.vertForet,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}
