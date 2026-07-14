import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/models/client_models.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/quantity_selector_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/cart_service.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  Map<String, dynamic>? _selectedSideMap;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final product = ModalRoute.of(context)!.settings.arguments as Produit;
      if (product.accompaniments.isNotEmpty) {
        _selectedSideMap = Map<String, dynamic>.from(
          product.accompaniments.first,
        );
      } else {
        _selectedSideMap = null;
      }
      _isInit = false;
    }
  }

  double _calculateTotalPrice(double productPrice) {
    double accPrice = 0.0;
    if (_selectedSideMap != null) {
      accPrice = (_selectedSideMap!['prix_unit'] as num?)?.toDouble() ?? 0.0;
    }
    return (productPrice + accPrice) * _quantity;
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
          _selectedSideMap = acc;
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
    final product = ModalRoute.of(context)!.settings.arguments as Produit;

    // Generate background pastel color based on product ID
    final List<Color> bgColors = [
      const Color(0xFFFFF0EA), // light orange
      const Color(0xFFE8F5E9), // light green
      const Color(0xFFFCE4EC), // light pink
      const Color(0xFFFFFDE7), // light yellow
    ];
    final int colorIndex = product.id.hashCode % bgColors.length;
    final Color bgColor = bgColors[colorIndex];

    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          "Détails du Produit",
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Large Product Display Section
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
                      child:
                          product.photoUrl != null &&
                              product.photoUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(
                                product.photoUrl!,
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Text(
                                        product.emoji,
                                        style: const TextStyle(fontSize: 100),
                                      ),
                                    ),
                              ),
                            )
                          : Center(
                              child: Text(
                                product.emoji,
                                style: const TextStyle(fontSize: 100),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Product Name
                  Text(
                    product.name,
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
                              "${product.rating.toStringAsFixed(1)} (${product.ratingCount} avis)",
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
                              product.prepMinutes != null
                                  ? "Prêt en ${product.prepMinutes} min"
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
                              "${product.shopLocation} · 2,1 km",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8D7A68),
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
                              (product.description != null &&
                                  product.description!.isNotEmpty)
                              ? "${product.description}. Vendu par "
                              : "Porc braisé au feu de bois, mariné aux épices maison. Vendu par ",
                        ),
                        TextSpan(
                          text: product.shopName,
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
                  if (product.accompaniments.isNotEmpty) ...[
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
                      children: product.accompaniments.map((acc) {
                        return _buildSideChip(acc as Map<String, dynamic>);
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Quantity Selector
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
                      final accName =
                          _selectedSideMap?['name'] ?? 'Sans accompagnement';
                      final accPrice =
                          (_selectedSideMap?['prix_unit'] as num?)
                              ?.toDouble() ??
                          0.0;

                      CartService.instance.addToCart(
                        productId: product.id,
                        productName: product.name,
                        productPrice: product.price,
                        productPhotoUrl: product.photoUrl,
                        productEmoji: product.emoji,
                        shopName: product.shopName,
                        quantity: _quantity,
                        selectedSide: accName,
                        selectedSidePrice: accPrice,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${product.name} (x$_quantity) avec $accName ajouté au panier !",
                          ),
                          backgroundColor: CdaColors.vertForet,
                        ),
                      );
                      Navigator.pop(context);
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
                          "${_calculateTotalPrice(product.price).toInt()} F",
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
