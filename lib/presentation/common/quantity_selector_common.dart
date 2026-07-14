import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';

class QuantitySelectorCommon extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String? label;
  final double btnSize;
  final double fontSize;

  const QuantitySelectorCommon({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.label,
    this.btnSize = 44,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: btnSize,
            height: btnSize,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5D5C5),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.remove,
              color: CdaColors.encre,
              size: btnSize * 0.45,
            ),
          ),
        ),
        SizedBox(width: btnSize * 0.45),
        Text(
          quantity.toString(),
          style: GoogleFonts.nunito(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: CdaColors.encre,
          ),
        ),
        SizedBox(width: btnSize * 0.45),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: btnSize,
            height: btnSize,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5D5C5),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.add,
              color: CdaColors.encre,
              size: btnSize * 0.45,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 16),
          Text(
            label!,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: CdaColors.gris,
            ),
          ),
        ],
      ],
    );
  }
}
