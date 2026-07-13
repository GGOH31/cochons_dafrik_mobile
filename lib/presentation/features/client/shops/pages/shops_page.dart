import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/core/models/client_models.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/boutiquue_card_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/client_service.dart';

class ShopsPage extends StatefulWidget {
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  final ClientService _clientService = ClientService();
  List<Boutique> _boutiques = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final shopsJson = await _clientService.getShops();
      setState(() {
        _boutiques = shopsJson.map((s) => Boutique.fromJson(s)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Erreur lors du chargement des boutiques: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredShops = _boutiques.where((b) {
      final query = _searchQuery.toLowerCase();
      return b.name.toLowerCase().contains(query) ||
          b.speciality.toLowerCase().contains(query) ||
          b.location.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          "Toutes les Boutiques",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Search Bar for Shops
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  icon: const Icon(
                    LucideIcons.search,
                    color: CdaColors.gris,
                    size: 20,
                  ),
                  hintText: "Rechercher une boutique...",
                  hintStyle: GoogleFonts.nunito(
                    color: CdaColors.gris,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(CdaColors.vertForet),
                      ),
                    )
                  : filteredShops.isEmpty
                      ? Center(
                          child: Text(
                            "Aucune boutique trouvée",
                            style: GoogleFonts.nunito(
                              color: CdaColors.gris,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filteredShops.length,
                          itemBuilder: (context, index) {
                            final boutique = filteredShops[index];
                            return BoutiqueCard(
                              boutique: boutique,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.productClient,
                                  arguments: boutique,
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
