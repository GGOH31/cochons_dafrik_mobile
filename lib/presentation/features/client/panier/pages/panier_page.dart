import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/quantity_selector_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/domains/services/cart_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/client/paiements/pages/paiement_page.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';

class PanierPage extends StatefulWidget {
  final VoidCallback? onDiscoverTap;

  const PanierPage({super.key, this.onDiscoverTap});

  @override
  State<PanierPage> createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  @override
  void initState() {
    super.initState();
    CartService.instance.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          "Mon Panier",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: CdaColors.encre,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartService.instance.cartNotifier,
            builder: (context, items, _) {
              if (items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(LucideIcons.trash2, color: CdaColors.rouge),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        "Vider le panier",
                        style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        "Voulez-vous vraiment vider tout le panier ?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Annuler",
                            style: GoogleFonts.nunito(color: CdaColors.gris),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            CartService.instance.clearCart();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Vider",
                            style: GoogleFonts.nunito(
                              color: CdaColors.rouge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartService.instance.cartNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return _buildEmptyState();
          }
          return _buildCartList(context, items);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CdaColors.jaune.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.shoppingCart,
              size: 64,
              color: CdaColors.jaune,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Votre panier est vide",
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CdaColors.encre,
            ),
          ),

          const SizedBox(height: 24),
          CdaElevatedButton(
            text: "Faire mes achats",
            onPressed: widget.onDiscoverTap,
            backgroundColor: CdaColors.vertForet,
            foregroundColor: Colors.white,
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, List<CartItem> items) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final itemTotal =
                  (item.productPrice + item.selectedSidePrice) * item.quantity;

              // Generate background color based on product ID
              final List<Color> bgColors = [
                const Color(0xFFFFF0EA),
                const Color(0xFFE8F5E9),
                const Color(0xFFFCE4EC),
                const Color(0xFFFFFDE7),
              ];
              final int colorIndex = item.productId.hashCode % bgColors.length;
              final Color bgColor = bgColors[colorIndex];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo display
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            item.productPhotoUrl != null &&
                                item.productPhotoUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  item.productPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Text(
                                          item.productEmoji,
                                          style: const TextStyle(fontSize: 36),
                                        ),
                                      ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  item.productEmoji,
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CdaColors.encre,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Boutique : ${item.shopName}",
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: CdaColors.gris,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Accompagnement : ${item.selectedSide}",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: CdaColors.vertForet,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Price and Quantity Selector
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${itemTotal.toInt()} F",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CdaColors.vertForet,
                                  ),
                                ),
                                QuantitySelectorCommon(
                                  quantity: item.quantity,
                                  btnSize: 32,
                                  fontSize: 15,
                                  onIncrement: () {
                                    CartService.instance.updateQuantity(
                                      item.id,
                                      item.quantity + 1,
                                    );
                                  },
                                  onDecrement: () {
                                    CartService.instance.updateQuantity(
                                      item.id,
                                      item.quantity - 1,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Remove button
                      IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          color: CdaColors.gris,
                          size: 18,
                        ),
                        onPressed: () {
                          CartService.instance.removeFromCart(item.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Checkout Section
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.encre,
                    ),
                  ),
                  Text(
                    "${CartService.instance.totalAmount.toInt()} F",
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CdaColors.vertForet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CdaElevatedButton(
                text: "Passer la commande",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaiementPage(),
                    ),
                  );
                },
                backgroundColor: CdaColors.vertForet,
                foregroundColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
