import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redine_frontend/widgets/custom_button.dart';
import 'search_bar.dart';
import 'chip_list.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> selectedAllergens;
  final List<String> selectedAvoids;
  final List<String> selectedCategories;
  final List<String> selectedNationalities;

  final List<String> fetchAllergens;
  final List<String> fetchAvoids;
  final List<String> fetchCategories;
  final List<String> fetchNationalities;

  final Future<void> Function() fetchMealIngredients;

  final Function({
    required List<String> allergens,
    required List<String> avoids,
    required List<String> categories,
    required List<String> nationalities,
  })
  onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedAllergens,
    required this.selectedAvoids,
    required this.selectedCategories,
    required this.selectedNationalities,
    required this.onApply,
    required this.fetchMealIngredients,
    required this.fetchAllergens,
    required this.fetchAvoids,
    required this.fetchCategories,
    required this.fetchNationalities,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final SearchController _allergenController = SearchController();
  final SearchController _avoidController = SearchController();
  final SearchController _categoryController = SearchController();
  final SearchController _nationalityController = SearchController();

  final List<String> _selectedAllergens = [];
  final List<String> _selectedAvoids = [];
  final List<String> _selectedCategories = [];
  final List<String> _selectedNationalities = [];

  @override
  void initState() {
    super.initState();
    _selectedAllergens.addAll(widget.selectedAllergens);
    _selectedAvoids.addAll(widget.selectedAvoids);
    _selectedCategories.addAll(widget.selectedCategories);
    _selectedNationalities.addAll(widget.selectedNationalities);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.75,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top bar
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Filter',
                  style: GoogleFonts.livvic(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedAllergens.clear();
                          _selectedAvoids.clear();
                          _selectedCategories.clear();
                          _selectedNationalities.clear();
                        });
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: Color(0xFF54AF75),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // const Divider(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilterSectionWidget(
                        title: 'Allergen',
                        hintText: 'e.g. Milk, Peanuts, Shellfish',
                        controller: _allergenController,
                        selectedChips: _selectedAllergens,
                        allSuggestions: widget.fetchAllergens,
                        onChipAdded: (chip) {
                          setState(() {
                            if (!_selectedAllergens.contains(chip)) {
                              _selectedAllergens.add(chip);
                            }
                          });
                        },
                        onChipDeleted: (chip) {
                          setState(() {
                            _selectedAllergens.remove(chip);
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      FilterSectionWidget(
                        title: 'Avoid',
                        hintText: 'e.g. Garlic, Beef, Mushrooms',
                        controller: _avoidController,
                        selectedChips: _selectedAvoids,
                        allSuggestions: widget.fetchAvoids,
                        onChipAdded: (chip) {
                          setState(() {
                            if (!_selectedAvoids.contains(chip)) {
                              _selectedAvoids.add(chip);
                            }
                          });
                        },
                        onChipDeleted: (chip) {
                          setState(() {
                            _selectedAvoids.remove(chip);
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '*Recipes with these allergens or avoided ingredients will be excluded.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                      Divider(),
                      const SizedBox(height: 15),
                      FilterSectionWidget(
                        title: 'Category',
                        hintText: 'e.g., Vegan, Pasta, Seafood',
                        controller: _categoryController,
                        selectedChips: _selectedCategories,
                        allSuggestions: widget.fetchCategories,
                        onChipDeleted: (chip) {
                          setState(() {
                            _selectedCategories.remove(chip);
                          });
                        },
                        onChipAdded: (chip) {
                          setState(() {
                            if (!_selectedCategories.contains(chip)) {
                              _selectedCategories.add(chip);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      FilterSectionWidget(
                        title: 'Nationality',
                        hintText: 'e.g., Italian, Chinese, Indian',
                        controller: _nationalityController,
                        selectedChips: _selectedNationalities,
                        allSuggestions: widget.fetchNationalities,
                        onChipDeleted: (chip) {
                          setState(() {
                            _selectedNationalities.remove(chip);
                          });
                        },
                        onChipAdded: (chip) {
                          setState(() {
                            if (!_selectedNationalities.contains(chip)) {
                              _selectedNationalities.add(chip);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Apply button
            Padding(
              padding: EdgeInsets.all(20),
              child: CustomButton(
                label: 'Apply',
                onPressed: () {
                  widget.onApply(
                    allergens: _selectedAllergens,
                    avoids: _selectedAvoids,
                    categories: _selectedCategories,
                    nationalities: _selectedNationalities,
                  );
                  widget.fetchMealIngredients();
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

// Reusable Filter Section Widget
class FilterSectionWidget extends StatelessWidget {
  final String title;
  final String hintText;
  final SearchController controller;
  final List<String> selectedChips;
  final List<String> allSuggestions;
  final Function(String) onChipDeleted;
  final Function(String) onChipAdded;

  const FilterSectionWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.selectedChips,
    required this.allSuggestions,
    required this.onChipDeleted,
    required this.onChipAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.livvic(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Reuse SearchBarWidget
        SizedBox(
          width: double.infinity,
          child: SearchBarWidget(
            barHintText: hintText,
            searchController: controller,
            allSuggestions: allSuggestions,
            onItemSelected: (item) {
              onChipAdded(item);
            },
          ),
        ),
        const SizedBox(height: 8),
        // Reuse ChipListWidget
        ChipListWidget(chips: selectedChips, onChipDeleted: onChipDeleted),
      ],
    );
  }
}
