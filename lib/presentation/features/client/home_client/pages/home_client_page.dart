import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cochons_dafrik_mobile/core/constants/app_routes.dart';
import 'package:cochons_dafrik_mobile/core/models/client_models.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/appHeaderBanner_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/restaurant_card_common.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_dish_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/commande_client/pages/commande_client_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/panier/pages/panier_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/profil_client/pages/profil_client_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/client_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/cart_service.dart';

class HomeClientPage extends StatefulWidget {
  const HomeClientPage({super.key});

  @override
  State<HomeClientPage> createState() => _HomeClientPageState();
}

class _HomeClientPageState extends State<HomeClientPage> {
  int _currentTab = 0;
  String _userName = 'Awa';
  String _locationLabel = "• Cocody, Abidjan";
  final ClientService _clientService = ClientService();
  List<Restaurant> _restaurants = [];
  bool _isShopsLoading = true;

  String _searchQuery = "";
  List<Dish> _searchResults = [];
  bool _isSearchLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _determinePosition();
    _fetchShops();
    CartService.instance.loadCart();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchQuery = "";
        _searchResults = [];
        _isSearchLoading = false;
      });
      return;
    }

    setState(() {
      _searchQuery = trimmed;
      _isSearchLoading = true;
    });

    try {
      final resultsJson = await _clientService.searchDishes(trimmed);
      setState(() {
        _searchResults = resultsJson.map((p) {
          final restaurant = p['restaurant'] ?? {};
          final restaurantName = restaurant['name'] ?? 'Restaurant';
          final restaurantLocation = restaurant['commune'] ?? 'Cocody';
          return Dish.fromJson(
            p,
            restaurantName,
            restaurantLocation: restaurantLocation,
          );
        }).toList();
        _isSearchLoading = false;
      });
    } catch (e) {
      setState(() {
        _isSearchLoading = false;
      });
      debugPrint("Erreur lors de la recherche des dishes: $e");
    }
  }

  Future<void> _fetchShops() async {
    setState(() {
      _isShopsLoading = true;
    });
    try {
      final shopsJson = await _clientService.getRestaurants();
      setState(() {
        _restaurants = shopsJson.map((s) => Restaurant.fromJson(s)).toList();
        _isShopsLoading = false;
      });
    } catch (e) {
      setState(() {
        _isShopsLoading = false;
      });
      debugPrint("Erreur lors du chargement des restaurants: $e");
    }
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

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      final geocoding = Geocoding();
      final List<Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        final String? subLocality = place.subLocality;
        final String? locality = place.locality;

        String commune = 'Cocody';
        if (subLocality != null && subLocality.isNotEmpty) {
          commune = subLocality;
        } else if (locality != null && locality.isNotEmpty) {
          commune = locality;
        }

        setState(() {
          _locationLabel = "• $commune, Abidjan";
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération de la localisation: $e");
    }
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
          items: [
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Accueil',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.fileText),
              label: 'Commandes',
            ),
            BottomNavigationBarItem(
              icon: ValueListenableBuilder<List<CartItem>>(
                valueListenable: CartService.instance.cartNotifier,
                builder: (context, cartItems, _) {
                  final totalQuantity = cartItems.fold<int>(
                    0,
                    (sum, item) => sum + item.quantity,
                  );
                  if (totalQuantity == 0) {
                    return const Icon(LucideIcons.shoppingCart);
                  }
                  return Badge(
                    label: Text(
                      totalQuantity.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: CdaColors.rouge,
                    child: const Icon(LucideIcons.shoppingCart),
                  );
                },
              ),
              label: 'Panier',
            ),
            const BottomNavigationBarItem(
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
        return CommandeClientPage(
          onDiscoverTap: () => setState(() => _currentTab = 0),
        );
      case 2:
        return PanierPage(onDiscoverTap: () => setState(() => _currentTab = 0));
      case 3:
        return ProfilClientPage();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHeaderContent({bool isPlaceholder = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Bonjour $_userName 👋 ",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  _locationLabel,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Une envie de porc braisé ?",
          style: GoogleFonts.fredoka(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        // Champ de recherche
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: isPlaceholder
              ? const SizedBox(
                  height: 48,
                ) // Matches standard TextField height approximately
              : TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _performSearch,
                  onChanged: (val) {
                    setState(() {});
                    if (val.trim().isEmpty) {
                      _performSearch("");
                    }
                  },
                  decoration: InputDecoration(
                    icon: const Icon(
                      LucideIcons.search,
                      color: CdaColors.gris,
                      size: 20,
                    ),
                    hintText: "Porc braisé, porc au four...",
                    hintStyle: GoogleFonts.nunito(
                      color: CdaColors.gris,
                      fontSize: 15,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _performSearch("");
                            },
                            child: const Icon(
                              Icons.clear,
                              color: CdaColors.gris,
                              size: 20,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // --- TAB 0: ACCUEIL ---
  Widget _buildHomeTab() {
    final headerContent = _buildHeaderContent();

    return Stack(
      children: [
        // 1. Main Layout (fixed header banner + expanded scrollable list)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeaderBanner(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
              child: headerContent,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 36,
                    ), // Spacing to clear the floating badge
                    // Bannière Promo
                    // Container(
                    //   width: double.infinity,
                    //   height: 90,
                    //   margin: const EdgeInsets.symmetric(horizontal: 20),
                    //   decoration: BoxDecoration(
                    //     color: CdaColors.rouge,
                    //     borderRadius: BorderRadius.circular(20),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: CdaColors.rouge.withOpacity(0.2),
                    //         blurRadius: 8,
                    //         offset: const Offset(0, 4),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Stack(
                    //     children: [
                    //       Positioned(
                    //         left: 20,
                    //         top: 25,
                    //         bottom: 25,
                    //         child: Container(
                    //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    //           decoration: BoxDecoration(
                    //             color: CdaColors.jaune,
                    //             borderRadius: BorderRadius.circular(10),
                    //           ),
                    //           child: Center(
                    //             child: Text(
                    //               "PROMO -20%",
                    //               style: GoogleFonts.fredoka(
                    //                 fontWeight: FontWeight.bold,
                    //                 color: CdaColors.encre,
                    //                 fontSize: 13,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       Positioned(
                    //         right: 20,
                    //         top: 0,
                    //         bottom: 0,
                    //         child: Center(
                    //           child: Text(
                    //             "Sur votre première commande !",
                    //             style: GoogleFonts.nunito(
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.bold,
                    //               fontSize: 14,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    if (_searchQuery.isNotEmpty) ...[
                      // Search Results view
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Résultats de recherche",
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.encre,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                _performSearch("");
                              },
                              child: Text(
                                "Annuler",
                                style: GoogleFonts.nunito(
                                  color: CdaColors.rouge,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _isSearchLoading
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
                          : _searchResults.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40.0,
                                ),
                                child: Text(
                                  "Aucun dish trouvé pour \"$_searchQuery\"",
                                  style: GoogleFonts.nunito(
                                    color: CdaColors.gris,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.82,
                                    ),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final dish = _searchResults[index];
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
                                      try {
                                        CartService.instance.addToCart(
                                          dishId: dish.id,
                                          restaurantId: dish.restaurantId,
                                          productName: dish.name,
                                          productPrice: dish.price,
                                          productPhotoUrl: dish.photoUrl,
                                          productEmoji: dish.emoji,
                                          restaurantName: dish.restaurantName,
                                          quantity: 1,
                                          selectedSide:
                                              dish.accompaniments.isNotEmpty
                                              ? (dish
                                                        .accompaniments
                                                        .first['name'] ??
                                                    'Sans accompagnement')
                                              : 'Sans accompagnement',
                                          selectedSidePrice:
                                              dish.accompaniments.isNotEmpty
                                              ? ((dish
                                                                .accompaniments
                                                                .first['prix_unit']
                                                            as num?)
                                                        ?.toDouble() ??
                                                    0.0)
                                              : 0.0,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${dish.name} ajouté au panier !",
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                            backgroundColor:
                                                CdaColors.vertForet,
                                          ),
                                        );
                                      } catch (e) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              "Restaurant différent",
                                              style: GoogleFonts.fredoka(
                                                color: CdaColors.rouge,
                                              ),
                                            ),
                                            content: Text(
                                              e.toString().replaceAll(
                                                "Exception: ",
                                                "",
                                              ),
                                              style: GoogleFonts.nunito(),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  "Annuler",
                                                  style: GoogleFonts.nunito(
                                                    color: CdaColors.gris,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  CartService.instance
                                                      .clearCart();
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Panier vidé. Vous pouvez maintenant ajouter ce plat.",
                                                      ),
                                                      backgroundColor:
                                                          CdaColors.vertForet,
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "Vider le panier",
                                                  style: GoogleFonts.nunito(
                                                    color: CdaColors.rouge,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                      const SizedBox(height: 40),
                    ] else ...[
                      Column(
                        children: [
                          // Section Title "Populaires près de vous"
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Populaires près de vous",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: CdaColors.encre,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.restaurants,
                                  ),
                                  child: Text(
                                    "Voir tout",
                                    style: GoogleFonts.nunito(
                                      color: CdaColors.rouge,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Grille des Restaurants
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: _isShopsLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        CdaColors.vertForet,
                                      ),
                                    ),
                                  )
                                : _restaurants.isEmpty
                                ? Center(
                                    child: Text(
                                      "Aucune restaurant disponible",
                                      style: GoogleFonts.nunito(
                                        color: CdaColors.gris,
                                        fontSize: 15,
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          childAspectRatio: 0.85,
                                        ),
                                    itemCount: _restaurants.length,
                                    itemBuilder: (context, index) {
                                      final restaurant = _restaurants[index];
                                      return RestaurantCard(
                                        restaurant: restaurant,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.productClient,
                                            arguments: restaurant,
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // 2. Floating Badge Overlay (z-indexed above the scrollable content)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IgnorePointer(
                  child: Opacity(
                    opacity: 0.0,
                    child: AppHeaderBanner(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
                      child: _buildHeaderContent(isPlaceholder: true),
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
                        horizontal: 24,
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
                          const Text("🔥 ", style: TextStyle(fontSize: 16)),
                          Text(
                            _isShopsLoading
                                ? "Recherche de restaurants..."
                                : "${_restaurants.length} restaurants ouvertes près de vous",
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
      ],
    );
  }
}
