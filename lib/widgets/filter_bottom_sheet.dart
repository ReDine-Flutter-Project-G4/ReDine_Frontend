import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search_bar_widget.dart';
import 'chip_list_widget.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> selectedAvoidances;
  final List<String> selectedCategories;
  final List<String> selectedNationalities;

  final List<String> fetchAvoidances;
  final List<String> fetchCategories;
  final List<String> fetchNationalities;

  final Future<void> Function() fetchMealIngredients;

  final Function({
    required List<String> avoidances,
    required List<String> categories,
    required List<String> nationalities,
  })
  onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedAvoidances,
    required this.selectedCategories,
    required this.selectedNationalities,
    required this.onApply,
    required this.fetchMealIngredients,
    required this.fetchAvoidances,
    required this.fetchCategories,
    required this.fetchNationalities,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final SearchController _avoidanceController = SearchController();
  final SearchController _categoryController = SearchController();
  final SearchController _nationalityController = SearchController();

  final List<String> _selectedAvoidances = [];
  final List<String> _selectedCategories = [];
  final List<String> _selectedNationalities = [];

  @override
  void initState() {
    super.initState();
    _selectedAvoidances.addAll(widget.selectedAvoidances);
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedAvoidances.clear();
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
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilterSectionWidget(
                        title: 'Avoidances',
                        hintText: 'e.g., Nuts, Milk, Fish',
                        controller: _avoidanceController,
                        selectedChips: _selectedAvoidances,
                        allSuggestions: widget.fetchAvoidances,
                        onChipAdded: (chip) {
                          setState(() {
                            if (!_selectedAvoidances.contains(chip)) {
                              _selectedAvoidances.add(chip);
                            }
                          });
                        },
                        onChipDeleted: (chip) {
                          setState(() {
                            _selectedAvoidances.remove(chip);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
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

            const SizedBox(height: 16),

            // Apply button
            Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      avoidances: _selectedAvoidances,
                      categories: _selectedCategories,
                      nationalities: _selectedNationalities,
                    );
                    widget.fetchMealIngredients();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF54AF75),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.livvic(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
        Text(
          title,
          style: GoogleFonts.livvic(fontWeight: FontWeight.w700, fontSize: 18),
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
