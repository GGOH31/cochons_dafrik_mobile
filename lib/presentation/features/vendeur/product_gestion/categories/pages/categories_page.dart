import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_categorie_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/categories/pages/category_form_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<Map<String, dynamic>> _categories = [
    {"name": "Grillades", "emoji": "🍖", "count": 4},
    {"name": "Accompagnements", "emoji": "🥗", "count": 3},
    {"name": "Boissons", "emoji": "🥤", "count": 5},
    {"name": "Formules Midi", "emoji": "🍱", "count": 2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return CardCategorieCommon(
            name: cat["name"],
            emoji: cat["emoji"],
            count: cat["count"],
            onDelete: () {
              setState(() {
                _categories.removeAt(index);
              });
            },
            onTap: () async {
              final result = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryFormPage(initialCategory: cat),
                ),
              );
              if (result != null) {
                setState(() {
                  _categories[index] = {
                    "name": result["name"],
                    "emoji": result["emoji"],
                    "count": cat["count"],
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
              builder: (context) => const CategoryFormPage(),
            ),
          );
          if (result != null) {
            setState(() {
              _categories.add({
                "name": result["name"],
                "emoji": result["emoji"],
                "count": 0,
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
