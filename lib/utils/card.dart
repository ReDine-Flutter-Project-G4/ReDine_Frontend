import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Card extends StatelessWidget {
  const Card({
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
    return Container(
      width: 153,
      height: 800,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  width: double.infinity,
                  height: 110,
                  child: Image.network(strMealThumb, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strMeal,
                style: GoogleFonts.livvic(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 6,
                children: [_buildTag(strArea), _buildTag(strCategory)],
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF020202),
                  ),
                  children: [
                    const TextSpan(text: 'Ingredient: '),
                    TextSpan(text: strIngredients.join(', ')),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTag(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF54AF75),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

}
