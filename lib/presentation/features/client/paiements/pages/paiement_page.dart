import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/appHeaderBanner_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/cart_service.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';

class PaiementPage extends StatefulWidget {
  const PaiementPage({super.key});

  @override
  State<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  String _selectedMethod = 'wave'; // orange, mtn, wave, card
  final double _deliveryFee = 1000.0;

  Widget _buildPaymentOption({
    required String methodId,
    required Widget iconWidget,
    required String title,
    String? subTitle,
  }) {
    final isSelected = _selectedMethod == methodId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = methodId;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? CdaColors.vertForet : const Color(0xFFE5D5C5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Custom Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? CdaColors.vertForet : CdaColors.gris,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: CdaColors.vertForet,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Brand Icon Container
            iconWidget,
            const SizedBox(width: 16),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  if (subTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subTitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: CdaColors.gris,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartService = CartService.instance;
    final totalProducts = cartService.totalAmount;
    final totalToPay = totalProducts + _deliveryFee;
    final cartItems = cartService.items;

    return Scaffold(
      backgroundColor: CdaColors.creme,
      body: Column(
        children: [
          // Header using AppHeaderBanner and Stack for yellow banner overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppHeaderBanner(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 36),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Paiement sécurisé",
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Secured payment notification banner overlaid at the bottom of the header
              Positioned(
                bottom: -20,
                left: 20,
                right: 20,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.lock,
                        size: 16,
                        color: CdaColors.encre,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Payé avant cuisson . protégé Cochons d'Afrik",
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: CdaColors.encre,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Main body content (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE5D5C5),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Cart items list in summary
                        ...cartItems.map((item) {
                          final itemTotal =
                              (item.productPrice + item.selectedSidePrice) *
                              item.quantity;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${item.quantity} × ${item.productName}",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: CdaColors.gris,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "${itemTotal.toInt()} F",
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: CdaColors.encre,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        // Delivery fee
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Livraison . Cocody Riviera",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: CdaColors.gris,
                                ),
                              ),
                              Text(
                                "${_deliveryFee.toInt()} F",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: CdaColors.encre,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFE5D5C5), thickness: 1),
                        const SizedBox(height: 4),
                        // Total to pay
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total à payer",
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.encre,
                              ),
                            ),
                            Text(
                              "${totalToPay.toInt()} F",
                              style: GoogleFonts.fredoka(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.vertForet,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Middle Section Title
                  Text(
                    "Moyen de paiement",
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.vertForet,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wave
                  _buildPaymentOption(
                    methodId: 'wave',
                    iconWidget: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D9BF0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Image.asset("assets/pictures/wave.png"),
                      ),
                    ),
                    title: "Wave",
                  ),

                  // Escrow notification banner (orange border/bg)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFFFB300),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("🛡️ ", style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            "Paiement séquestre : le vendeur lance la cuisson dès votre paiement, mais n'est payé qu'après votre confirmation de réception.",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5D4037),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
            child: CdaElevatedButton(
              backgroundColor: const Color(0xFFFFA000), // Nice brand orange yellow
              foregroundColor: CdaColors.encre,
              height: 52,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Commande et paiement enregistrés avec succès !",
                    ),
                    backgroundColor: CdaColors.vertForet,
                  ),
                );
                cartService.clearCart();
                // Return back to Home tab 0
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Payer maintenant",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  Text(
                    "${totalToPay.toInt()} F",
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
