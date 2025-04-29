import 'dart:async';

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

  final List<String> _selectedAllergies = [];
  final List<String> _selectedCategories = [];
  final List<String> _selectedNationalities = [];
  final List<String> _selectedChips = [];
  List<dynamic> _mealData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool isFilterOpen = false;

  List<String> _allIngredients = [];
  List<String> _allCategories = [];
  List<String> _allNationalities = [];
  List<String> _allAllergies = [];

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    _fetchMealSuggestions();
    _fetchIngredients();
    _fetchCategories();
    _fetchNationality();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final url = 'http://localhost:3001/api/meta/categories';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _allCategories = List<String>.from(jsonResponse['categories']);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _allCategories = [];
          _errorMessage = 'No data found';
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
      });
    }
  }

  Future<void> _fetchNationality() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final url = 'http://localhost:3001/api/meta/areas';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _allNationalities = List<String>.from(jsonResponse['areas']);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _allNationalities = [];
          _errorMessage = 'No data found';
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
      });
    }
  }

  Future<void> _fetchIngredients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final url = 'http://localhost:3001/api/meta/ingredients';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _allIngredients = List<String>.from(jsonResponse['ingredients']);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _allIngredients = [];
          _errorMessage = 'No data found';
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
      });
    }
  }

  Future<void> _fetchMealSuggestions() async {
    await _fetchData('http://localhost:3001/api/menu/suggestion');
  }

  Future<void> _fetchMealIngredients() async {
    final ingredientsQuery = _selectedChips.join(',');
    final nationalityQuery = _selectedNationalities.join(',');
    final cateforyyQuery = _selectedCategories.join(',');
    final allergiesQuery = _selectedAllergies.join(',');
    await _fetchData(
      'http://localhost:3001/api/menu/ingredients?ingredients=$ingredientsQuery&nationality=$nationalityQuery&category=$cateforyyQuery&allergies=$allergiesQuery',
    );
  }

  Future<void> _fetchData(String url) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _mealData = jsonResponse['meals'];
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _mealData = [];
          _errorMessage = 'No data found';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _isLoading = false;
      });
    }
  }

  List<String> _extractIngredients(Map<String, dynamic> meal) {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      if (ingredient != null && ingredient.toString().isNotEmpty) {
        ingredients.add(ingredient);
      }
    }
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          _buildAppBar(context),

          if (_selectedChips.isNotEmpty) _buildChipList(),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_errorMessage.isNotEmpty) _buildErrorMessage(),
          if (_mealData.isNotEmpty && !_isLoading) _buildMealGrid(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
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
              onPressed: () => widget.tabController.animateTo(0),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SearchBarWidget(
                barHintText: 'Add your ingredient',
                searchController: _searchController,
                allSuggestions: _allIngredients,
                onItemSelected: (item) async {
                  if (!_selectedChips.contains(item)) {
                    setState(() => _selectedChips.add(item));
                    await _fetchMealIngredients();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isFilterOpen ? Color(0xFF54AF75) : Color(0xFFB6B6B6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.tune, color: Colors.white, size: 28),
                onPressed: () async {
                  setState(() {
                    isFilterOpen = true;
                  });
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    builder:
                        (context) => FilterBottomSheet(
                          selectedAllergies: _selectedAllergies,
                          selectedCategories: _selectedCategories,
                          selectedNationalities: _selectedNationalities,
                          onApply: ({
                            required List<String> allergies,
                            required List<String> categories,
                            required List<String> nationalities,
                          }) async {
                            setState(() {
                              _selectedAllergies
                                ..clear()
                                ..addAll(allergies);
                              _selectedCategories
                                ..clear()
                                ..addAll(categories);
                              _selectedNationalities
                                ..clear()
                                ..addAll(nationalities);
                            });
                          },
                          fetchMealIngredients: _fetchMealIngredients,
                          fetchMealSuggestions: _fetchMealSuggestions,
                          fetchAllergies: _allAllergies,
                          fetchCategories: _allCategories,
                          fetchNationalities: _allNationalities,
                        ),
                  );
                  setState(() {
                    isFilterOpen = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildChipList() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ChipListWidget(
          chips: _selectedChips,
          onChipDeleted: (chip) async {
            setState(() => _selectedChips.remove(chip));
            if (_selectedChips.isEmpty) {
              await _fetchMealSuggestions();
            } else {
              await _fetchMealIngredients();
            }
          },
        ),
      ),
    );
  }

  SliverFillRemaining _buildErrorMessage() {
    return SliverFillRemaining(
      child: Center(
        child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  SliverPadding _buildMealGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final meal = _mealData[index];
          return custom_card.Card(
            strMeal: meal['strMeal'],
            strMealThumb: meal['strMealThumb'],
            strArea: meal['strArea'],
            strCategory: meal['strCategory'],
            strIngredients: _extractIngredients(meal),
          );
        }, childCount: _mealData.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 2 / 2.5,
        ),
      ),
    );
  }
}
