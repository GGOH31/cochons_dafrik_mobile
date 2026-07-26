import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/models/client_models.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/quantity_selector_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/cart_service.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/panier/pages/panier_page.dart';
import 'package:cochons_dafrik_mobile/presentation/common/appBar_common.dart';

class DishDetailPage extends StatefulWidget {
  const DishDetailPage({super.key});

  @override
  State<DishDetailPage> createState() => _DishDetailPageState();
}

class _DishDetailPageState extends State<DishDetailPage> {
  int _quantity = 1;
  Map<String, dynamic>? _selectedSideMap;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _selectedSideMap = null;
      _isInit = false;
    }
  }

  double _calculateTotalPrice(double productPrice) {
    double accPrice = 0.0;
    if (_selectedSideMap != null) {
      accPrice = (_selectedSideMap!['prix_unit'] as num?)?.toDouble() ?? 0.0;
    }
    return productPrice + (accPrice * _quantity);
  }

  Widget _buildSideChip(Map<String, dynamic> acc) {
    final name = acc['name'] ?? '';
    final price = acc['prix_unit'] ?? 0;
    final displayLabel = price > 0 ? "$name (+$price F)" : name;

    final isSelected =
        _selectedSideMap != null && _selectedSideMap!['id'] == acc['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSideMap = null;
          } else {
            _selectedSideMap = acc;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? CdaColors.vertForet : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? CdaColors.vertForet : const Color(0xFFE5D5C5),
            width: 1.5,
          ),
        ),
        child: Text(
          displayLabel,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : CdaColors.encre,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dish = ModalRoute.of(context)!.settings.arguments as Dish;

    // Generate background pastel color based on dish ID
    final List<Color> bgColors = [
      const Color(0xFFFFF0EA), // light orange
      const Color(0xFFE8F5E9), // light green
      const Color(0xFFFCE4EC), // light pink
      const Color(0xFFFFFDE7), // light yellow
    ];
    final int colorIndex = dish.id.hashCode % bgColors.length;
    final Color bgColor = bgColors[colorIndex];

    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: const CdaAppBar(
        title: "Détails du Dish",
        backgroundColor: CdaColors.vertForet,
        foregroundColor: CdaColors.creme,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Large Dish Display Section
                  Center(
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: dish.photoUrl != null && dish.photoUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(
                                dish.photoUrl!,
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Text(
                                        dish.emoji,
                                        style: const TextStyle(fontSize: 100),
                                      ),
                                    ),
                              ),
                            )
                          : Center(
                              child: Text(
                                dish.emoji,
                                style: const TextStyle(fontSize: 100),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dish Name
                  Text(
                    dish.name,
                    style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Badges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFF4CAF50),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFF4CAF50),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${dish.rating.toStringAsFixed(1)} (${dish.ratingCount} avis)",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4CAF50),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6F0),
                          border: Border.all(
                            color: const Color(0xFFE5D5C5),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_filled,
                              color: Color(0xFF8D7A68),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dish.prepMinutes != null
                                  ? "Prêt en ${dish.prepMinutes} min"
                                  : "Prêt en 15 min",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8D7A68),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6F0),
                          border: Border.all(
                            color: const Color(0xFFE5D5C5),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFFC62828),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${dish.restaurantLocation} · 2,1 km",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8D7A68),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (dish.deliveryFeeFcfa != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            border: Border.all(
                              color: const Color(0xFF90CAF9),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.delivery_dining,
                                color: Color(0xFF1976D2),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Livraison: ${dish.deliveryFeeFcfa} F",
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1976D2),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (dish.deliveryZone != null &&
                          dish.deliveryZone!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            border: Border.all(
                              color: const Color(0xFFCE93D8),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.map,
                                color: Color(0xFF7B1FA2),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Zone: ${dish.deliveryZone}",
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF7B1FA2),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: CdaColors.gris,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text:
                              (dish.description != null &&
                                  dish.description!.isNotEmpty)
                              ? "${dish.description}. Vendu par "
                              : "Porc braisé au feu de bois, mariné aux épices maison. Vendu par ",
                        ),
                        TextSpan(
                          text: dish.restaurantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CdaColors.vertForet,
                          ),
                        ),
                        const TextSpan(text: "."),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Accompagnement Section
                  if (dish.accompaniments.isNotEmpty) ...[
                    Text(
                      "Accompagnement",
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CdaColors.vertForet,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: dish.accompaniments.map((acc) {
                        return _buildSideChip(acc as Map<String, dynamic>);
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Quantity Selector
                  if (dish.accompaniments.isNotEmpty)
                    QuantitySelectorCommon(
                      quantity: _quantity,
                      label: "portions",
                      onIncrement: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                      onDecrement: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Add to Cart Bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CdaElevatedButton(
                    backgroundColor: CdaColors.vertForet,
                    foregroundColor: Colors.white,
                    height: 56,
                    onPressed: () {
                      final accNameBase =
                          _selectedSideMap?['name'] ?? 'Sans accompagnement';
                      final accName =
                          dish.accompaniments.isNotEmpty &&
                              _selectedSideMap != null
                          ? "$_quantity x $accNameBase"
                          : accNameBase;
                      final accPrice =
                          (_selectedSideMap?['prix_unit'] as num?)
                              ?.toDouble() ??
                          0.0;

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
                          selectedSide: accName,
                          selectedSidePrice: accPrice * _quantity,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${dish.name} avec $accName ajouté au panier !",
                            ),
                            backgroundColor: CdaColors.vertForet,
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PanierPage(),
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
                              e.toString().replaceAll("Exception: ", ""),
                              style: GoogleFonts.nunito(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Annuler",
                                  style: GoogleFonts.nunito(
                                    color: CdaColors.gris,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  CartService.instance.clearCart();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Panier vidé. Vous pouvez maintenant ajouter ce plat.",
                                      ),
                                      backgroundColor: CdaColors.vertForet,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ajouter au panier",
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "${_calculateTotalPrice(dish.price).toInt()} F",
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
