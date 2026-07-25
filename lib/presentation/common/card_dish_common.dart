import 'package:flutter/material.dart';
import 'package:cochons_dafrik_mobile/core/models/client_models.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:google_fonts/google_fonts.dart';

class CardDishCommon extends StatelessWidget {
  final Dish dish;
  final VoidCallback? onAddTap;
  final VoidCallback? onTap;

  const CardDishCommon({
    super.key,
    required this.dish,
    this.onAddTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine a background color based on dish ID or index for card emoji container
    final List<Color> bgColors = [
      const Color(0xFFFFF0EA), // light orange
      const Color(0xFFE8F5E9), // light green
      const Color(0xFFFCE4EC), // light pink
      const Color(0xFFFFFDE7), // light yellow
    ];
    final int colorIndex = dish.id.hashCode % bgColors.length;
    final Color bgColor = bgColors[colorIndex];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top colored section with Image or Emoji
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: dish.photoUrl != null && dish.photoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.network(
                        dish.photoUrl!,
                        width: double.infinity,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            dish.emoji,
                            style: const TextStyle(fontSize: 44),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        dish.emoji,
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
            ),
            // Bottom details section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: CdaColors.encre,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish.restaurantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: CdaColors.gris,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 12, color: CdaColors.jaune),
                      const SizedBox(width: 2),
                      Text(
                        dish.rating.toString(),
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: CdaColors.gris,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${dish.price.toInt()} F",
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CdaColors.vertForet,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddTap,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: CdaColors.jaune,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: CdaColors.encre,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
