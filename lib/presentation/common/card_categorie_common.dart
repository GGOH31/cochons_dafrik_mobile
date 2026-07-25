import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';

class CardCategorieCommon extends StatelessWidget {
  final String name;
  final String emoji;
  final int count;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const CardCategorieCommon({
    super.key,
    required this.name,
    required this.emoji,
    required this.count,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CdaColors.ligne, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Text(emoji, style: const TextStyle(fontSize: 24)),
        title: Text(
          name,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: CdaColors.encre,
          ),
        ),
        subtitle: Text(
          "$count dish(s)",
          style: GoogleFonts.nunito(
            fontSize: 13,
            color: CdaColors.gris,
          ),
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(LucideIcons.trash, color: CdaColors.rouge, size: 18),
                onPressed: onDelete,
              )
            : const Icon(Icons.arrow_forward_ios, size: 14, color: CdaColors.gris),
      ),
    );
  }
}
