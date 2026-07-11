import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/card_commande_vendeur_common.dart';

class CommandeVendeurPage extends StatelessWidget {
  final VoidCallback? onViewAllOrders;

  const CommandeVendeurPage({super.key, this.onViewAllOrders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        title: Text(
          "Mes Commandes Reçues",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: CdaColors.encre,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildSectionHeader("En attente de traitement"),
          const SizedBox(height: 12),
          CardCommandeVendeurCommon(
            orderId: "#CDA-1043",
            customerName: "Awa K.",
            details: "2 × Porc braisé + attiéké",
            commune: "Cocody",
            price: "8 000 F",
            isNew: true,
            statusLabel: "NOUVELLE",
            statusColor: const Color(0xFFD68000),
            statusBg: const Color(0xFFFFF7EC),
            onAccept: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Commande acceptée."),
                  backgroundColor: CdaColors.vertForet,
                ),
              );
            },
            onReject: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Commande refusée."),
                  backgroundColor: CdaColors.rouge,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("En cours de cuisson / livraison"),
          const SizedBox(height: 12),
          CardCommandeVendeurCommon(
            orderId: "#CDA-1022",
            customerName: "Koffi N.",
            details: "1 × Porc au four ½ kg + alloco",
            commune: "Marcory",
            price: "6 000 F",
            isNew: false,
            statusLabel: "EN CUISSON",
            statusColor: const Color(0xFF1976D2),
            statusBg: const Color(0xFFE3F2FD),
          ),
          const SizedBox(height: 12),
          CardCommandeVendeurCommon(
            orderId: "#CDA-1011",
            customerName: "Yasmine Z.",
            details: "3 × Côtelettes de porc + frites",
            commune: "Riviera 3",
            price: "15 500 F",
            isNew: false,
            statusLabel: "PRÊT / EN ROUTE",
            statusColor: const Color(0xFF2E7D32),
            statusBg: const Color(0xFFE8F5E9),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E6C40),
      ),
    );
  }
}
