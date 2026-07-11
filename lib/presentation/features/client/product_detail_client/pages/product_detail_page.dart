import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/models/client_models.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  String _selectedSide = "Attiéké";

  Widget _buildSideChip(String name) {
    final isSelected = _selectedSide == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSide = name;
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
          name,
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
                      child: Center(
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Color(0xFF4CAF50), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${product.rating} (126 avis)",
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6F0),
                          border: Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_filled, color: Color(0xFF8D7A68), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "Prêt en 35 min",
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6F0),
                          border: Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFFC62828), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${product.shopName == 'Maquis Bello' ? 'Yopougon' : product.shopName == 'Chez Tantie Porc' ? 'Cocody' : 'Marcory'} · 2,1 km",
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
                        const TextSpan(text: "Porc braisé au feu de bois, mariné aux épices maison. Servi avec attiéké, alloco ou frites, piment et oignons frais. Vendu par "),
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
                  Text(
                    "Accompagnement",
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.vertForet,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSideChip("Attiéké"),
                      const SizedBox(width: 10),
                      _buildSideChip("Alloco"),
                      const SizedBox(width: 10),
                      _buildSideChip("Frites"),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_quantity > 1) {
                            setState(() {
                              _quantity--;
                            });
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF6F0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
                          ),
                          child: const Icon(Icons.remove, color: CdaColors.encre),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        _quantity.toString(),
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: CdaColors.encre,
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF6F0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
                          ),
                          child: const Icon(Icons.add, color: CdaColors.encre),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "portions",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: CdaColors.gris,
                        ),
                      ),
                    ],
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
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${product.name} (x$_quantity) avec $_selectedSide ajouté au panier !"),
                          backgroundColor: CdaColors.vertForet,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CdaColors.vertForet,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 2,
                    ),
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
                          "${(_quantity * product.price).toInt()} F",
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
