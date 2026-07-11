import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/categories/pages/categories_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/products/pages/products_page.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/promotions/pages/promotions_page.dart';

class GestionsProductsCategoriesPromotionsPage extends StatelessWidget {
  const GestionsProductsCategoriesPromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: CdaColors.creme,
        body: Column(
          children: [
            // Header Banner with TabBar inside
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
              decoration: const BoxDecoration(
                color: CdaColors.vertForet,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mes produits & promos",
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.6),
                      labelStyle: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      unselectedLabelStyle: GoogleFonts.nunito(
                        fontSize: 15,
                      ),
                      tabs: const [
                        Tab(text: "Catégories"),
                        Tab(text: "Produits"),
                        Tab(text: "Promotions"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // TabBarView content
            const Expanded(
              child: TabBarView(
                children: [
                  CategoriesPage(),
                  ProductsPage(),
                  PromotionsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
