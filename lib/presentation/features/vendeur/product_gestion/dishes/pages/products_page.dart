import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_produit_vendeur_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/domains/services/vendeur_service.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/dishes/pages/product_form_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final VendeurService _vendeurService = VendeurService();
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _shopId;

  @override
  void initState() {
    super.initState();
    _loadShopIdAndProducts();
  }

  Future<void> _loadShopIdAndProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString != null) {
        final Map<String, dynamic> user = jsonDecode(userString);
        final restaurant = user['restaurant'];
        if (restaurant != null && restaurant['id'] != null) {
          _shopId = restaurant['id'].toString();
        }
      }
      await _fetchProducts();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dishes = await _vendeurService.getProducts();
      setState(() {
        _products = dishes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du chargement des dishes : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CdaColors.vertForet),
              ),
            )
          : _products.isEmpty
          ? Center(
              child: Text(
                "Aucun dish disponible",
                style: TextStyle(
                  color: CdaColors.gris,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchProducts,
              color: CdaColors.vertForet,
              child: ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final prod = _products[index];
                  final emoji = '🍖';
                  final isActive = prod['is_active'] ?? true;
                  final statusLabel = isActive ? "EN LIGNE" : "RUPTURE";
                  final statusColor = isActive
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828);
                  final statusBg = isActive
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE);

                  final price = prod['price_fcfa'] ?? 0;
                  final details = "$price FCFA";

                  return CardProduitVendeurCommon(
                    emoji: emoji,
                    photoUrl: prod["photo_url"],
                    name: prod["name"] ?? "",
                    statusLabel: statusLabel,
                    statusColor: statusColor,
                    statusBg: statusBg,
                    details: details,
                    onTap: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductFormPage(
                            initialProduct: prod,
                            restaurantId: _shopId,
                          ),
                        ),
                      );
                      if (result == true) {
                        _fetchProducts();
                      }
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => ProductFormPage(restaurantId: _shopId),
            ),
          );
          if (result == true) {
            _fetchProducts();
          }
        },
        backgroundColor: CdaColors.vertForet,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}
