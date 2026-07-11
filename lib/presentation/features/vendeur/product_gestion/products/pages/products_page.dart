import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_produit_vendeur_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/products/pages/product_form_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final List<Map<String, dynamic>> _products = [
    {
      "name": "Porc braisé (portion)",
      "emoji": "🍖",
      "statusLabel": "EN LIGNE",
      "statusColor": const Color(0xFF2E7D32),
      "statusBg": const Color(0xFFE8F5E9),
      "details": "3 500 F • promo -20% → 2 800 F • stock : illimité",
      "price": "3500",
      "isOnline": true,
      "category": "Grillades",
    },
    {
      "name": "Porc au four ½ kg",
      "emoji": "🐷",
      "statusLabel": "EN LIGNE",
      "statusColor": const Color(0xFF2E7D32),
      "statusBg": const Color(0xFFE8F5E9),
      "details": "5 000 F • prêt en 45 min",
      "price": "5000",
      "isOnline": true,
      "category": "Grillades",
    },
    {
      "name": "Porc braisé au kilo",
      "emoji": "🥩",
      "statusLabel": "RUPTURE",
      "statusColor": const Color(0xFFC62828),
      "statusBg": const Color(0xFFFFEBEE),
      "details": "7 000 F/kg • réapprovisionner via Viande fraîche",
      "price": "7000",
      "isOnline": false,
      "category": "Grillades",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final prod = _products[index];
          return CardProduitVendeurCommon(
            emoji: prod["emoji"],
            name: prod["name"],
            statusLabel: prod["statusLabel"],
            statusColor: prod["statusColor"],
            statusBg: prod["statusBg"],
            details: prod["details"],
            onTap: () async {
              final result = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormPage(initialProduct: prod),
                ),
              );
              if (result != null) {
                setState(() {
                  _products[index] = {
                    "name": result["name"],
                    "emoji": result["emoji"],
                    "price": result["price"],
                    "description": result["description"],
                    "isOnline": result["isOnline"],
                    "category": result["category"],
                    "statusLabel": result["isOnline"] ? "EN LIGNE" : "RUPTURE",
                    "statusColor": result["isOnline"] ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    "statusBg": result["isOnline"] ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    "details": "${result["price"]} F • ${result["category"]}",
                  };
                });
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormPage(),
            ),
          );
          if (result != null) {
            setState(() {
              _products.add({
                "name": result["name"],
                "emoji": result["emoji"],
                "price": result["price"],
                "description": result["description"],
                "isOnline": result["isOnline"],
                "category": result["category"],
                "statusLabel": result["isOnline"] ? "EN LIGNE" : "RUPTURE",
                "statusColor": result["isOnline"] ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                "statusBg": result["isOnline"] ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                "details": "${result["price"]} F • ${result["category"]}",
              });
            });
          }
        },
        backgroundColor: CdaColors.vertForet,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}
