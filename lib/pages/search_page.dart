import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/search_bar_widget.dart';
import '../widgets/chip_list_widget.dart';
import '../widgets/filter_bottom_sheet.dart';

import '../utils/card.dart' as custom_card;

class SearchTabPage extends StatefulWidget {
  final TabController tabController;
  const SearchTabPage({super.key, required this.tabController});

  @override
  State<SearchTabPage> createState() => _SearchTabPageState();
}

class _SearchTabPageState extends State<SearchTabPage> {
  late final SearchController _searchController;
  final List<String> allSuggestions = [
    'Chicken Breast',
    'Chicken Thighs',
    'Pork Belly',
    'Beef Ribs',
    'Bread',
    'Pork'
  ];
  final List<String> _selectedChips = [];
  List<dynamic> mealData = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> _MealsSuggestion() async {
    final apiUrl = 'http://localhost:3001/api/menu/suggestion';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          mealData = jsonResponse['meals'];
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'No suggestions found';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _FetchingIngredients() async {
    final baseUrl = 'http://localhost:3001/api/menu/ingredients';
    final ingredientsQuery = _selectedChips.join(',');
    final apiUrl = '$baseUrl?ingredients=$ingredientsQuery';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          mealData = jsonResponse['meals'];
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'No ingredients found';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    _MealsSuggestion();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            floating: true,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            toolbarHeight: 70,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 24,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      widget.tabController.animateTo(0);
                    },
                  ),
                  const SizedBox(width: 8),
                  // SearchAnchor
                  Expanded(
                    child: SearchBarWidget(
                      barHintText: 'Add your ingredient',
                      searchController: _searchController,
                      allSuggestions: allSuggestions,
                      onItemSelected: (item) async {
                        if (!_selectedChips.contains(item)) {
                          setState(() {
                            _selectedChips.add(item);
                          });
                          await _FetchingIngredients();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB6B6B6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const FilterBottomSheet(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_selectedChips.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ChipListWidget(
                  chips: _selectedChips,
                  onChipDeleted: (chip) {
                    setState(() {
                      _selectedChips.remove(chip);
                    });
                    if (_selectedChips.isEmpty) {
                      _MealsSuggestion();
                    } else {
                      _FetchingIngredients();
                    }
                  },
                ),
              ),
            ),
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          if (errorMessage.isNotEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          if (mealData.isNotEmpty && !isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final meal = mealData[index];
                  return custom_card.Card(
                    strMeal: meal['strMeal'],
                    strMealThumb: meal['strMealThumb'],
                    strArea: meal['strArea'],
                    strCategory: meal['strCategory'],
                    strIngredients: _getIngredients(meal),
                  );
                }, childCount: mealData.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 2 / 2.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<String> _getIngredients(Map<String, dynamic> meal) {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      if (meal['strIngredient$i'] != '' && meal['strIngredient$i'] != null) {
        ingredients.add('${meal['strIngredient$i']}');
      }
    }
    return ingredients;
  }
}
