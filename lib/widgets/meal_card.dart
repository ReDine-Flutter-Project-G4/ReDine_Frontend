import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redine_frontend/widgets/chip_tag.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.strMeal,
    required this.strMealThumb,
    required this.strArea,
    required this.strCategory,
    required this.strIngredients,
  });

  final String strMeal;
  final String strMealThumb;
  final String strArea;
  final String strCategory;
  final List<String> strIngredients;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int maxLines = (constraints.maxHeight / 75).clamp(2, 4).floor();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      strMealThumb,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strMeal,
                          style: GoogleFonts.livvic(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),

                        Wrap(
                          spacing: 6,
                          children: [
                            ChipTag(label: strArea),
                            ChipTag(label: strCategory),
                          ],
                        ),
                        const SizedBox(height: 5),

                        Expanded(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: maxLines,
                            text: TextSpan(
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Color(0xFF020202),
                              ),
                              children: [
                                TextSpan(text: 'Ingredient: ', style: GoogleFonts.livvic()),
                                TextSpan(text: strIngredients.join(', ')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
