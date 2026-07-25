import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/models/client_models.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/appHeaderBanner_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_dish_common.dart';
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/client_service.dart';

class DishClientPage extends StatefulWidget {
  const DishClientPage({super.key});

  @override
  State<DishClientPage> createState() => _DishClientPageState();
}

class _DishClientPageState extends State<DishClientPage> {
  final ClientService _clientService = ClientService();
  List<Dish> _products = [];
  bool _isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final restaurant =
          ModalRoute.of(context)!.settings.arguments as Restaurant;
      _fetchProducts(restaurant);
      _isInit = false;
    }
  }

  Future<void> _fetchProducts(Restaurant restaurant) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final productsJson = await _clientService.getRestaurantDishes(
        restaurant.id,
      );
      setState(() {
        _products = productsJson
            .map(
              (p) => Dish.fromJson(
                p,
                restaurant.name,
                restaurantLocation: restaurant.location,
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Erreur lors du chargement des dishes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = ModalRoute.of(context)!.settings.arguments as Restaurant;

    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          restaurant.name,
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: CdaColors.vertForet,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Details Header Banner
            AppHeaderBanner(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child:
                            restaurant.logoUrl != null &&
                                restaurant.logoUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.network(
                                  restaurant.logoUrl!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Text(
                                          restaurant.emoji,
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                      ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  restaurant.emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.speciality,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.mapPin,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.location,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: CdaColors.jaune,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.rating.toString(),
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dishes section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Sélectionne un plat",
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CdaColors.encre,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Dish Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CdaColors.vertForet,
                          ),
                        ),
                      ),
                    )
                  : _products.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          "Aucun dish disponible dans cette restaurant.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            color: CdaColors.gris,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.82,
                          ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final dish = _products[index];
                        return CardDishCommon(
                          dish: dish,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.productDetail,
                              arguments: dish,
                            );
                          },
                          onAddTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.productDetail,
                              arguments: dish,
                            );
                          },
                        );
                      },
                    ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
