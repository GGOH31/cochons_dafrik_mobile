import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_promotion_common.dart';
import 'package:cochons_dafrik_mobile/presentation/features/vendeur/product_gestion/promotions/pages/promotion_form_page.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  final List<Map<String, dynamic>> _promotions = [
    {
      "name": "-20% Week-end braisé",
      "percent": "20",
      "dates": "Ven. → Dim. • 34 ventes générées",
      "statusLabel": "PROMO ACTIVE",
      "statusColor": CdaColors.encre,
      "statusBg": const Color(0xFFFFC107),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _promotions.length,
        itemBuilder: (context, index) {
          final promo = _promotions[index];
          return CardPromotionCommon(
            title: promo["name"],
            details: promo["dates"],
            statusLabel: promo["statusLabel"],
            statusColor: promo["statusColor"],
            statusBg: promo["statusBg"],
            onTap: () async {
              final result = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) => PromotionFormPage(initialPromo: promo),
                ),
              );
              if (result != null) {
                setState(() {
                  _promotions[index] = {
                    "name": "-${result["percent"]}% ${result["name"]}",
                    "percent": result["percent"],
                    "dates": result["dates"],
                    "statusLabel": "PROMO ACTIVE",
                    "statusColor": CdaColors.encre,
                    "statusBg": const Color(0xFFFFC107),
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
              builder: (context) => const PromotionFormPage(),
            ),
          );
          if (result != null) {
            setState(() {
              _promotions.add({
                "name": "-${result["percent"]}% ${result["name"]}",
                "percent": result["percent"],
                "dates": result["dates"],
                "statusLabel": "PROMO ACTIVE",
                "statusColor": CdaColors.encre,
                "statusBg": const Color(0xFFFFC107),
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
