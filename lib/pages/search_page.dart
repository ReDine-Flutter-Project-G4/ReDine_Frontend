import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:redine_frontend/services/cache_service.dart';
import 'package:redine_frontend/services/firestore_service.dart';
import '../pages/detail_page.dart';
import '../components/search_bar.dart';
import '../components/chip_list.dart';
import '../components/filter_bottom_sheet.dart';
import '../pages/confirm_page.dart';
import '../widgets/meal_card.dart' as custom_card;
import '../config/api_config.dart';

Future<Map<String, List<String>>> loadCachedPreferences() async {
  final userData = await CacheService.loadUserPref();
  return {
    'avoids': List<String>.from(userData?['avoids'] ?? []),
    'allergens': List<String>.from(userData?['allergens'] ?? []),
  };
}

Future<void> _savePreferences(
  List<String> avoids,
  List<String> allergens,
) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    await Future.wait([
      FirestoreService.updatePreferences(uid, avoids, allergens),
      CacheService.updatePreferences(avoids, allergens),
    ]);
  }
}

class SearchTabPage extends StatefulWidget {
  final TabController tabController;
  final String? ingredient;
  const SearchTabPage({super.key, required this.tabController, this.ingredient});

  @override
  State<SearchTabPage> createState() => _SearchTabPageState();
}

class _SearchTabPageState extends State<SearchTabPage> {
  late final SearchController _searchController;
  final ImagePicker _picker = ImagePicker();

  final List<String> _selectedAllergens = [];
  final List<String> _selectedAvoids = [];
  final List<String> _selectedCategories = [];
  final List<String> _selectedNationalities = [];
  List<String> _selectedChips = [];
  List<dynamic> _mealData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool isFilterOpen = false;

  List<String> _allIngredients = [];
  List<String> _allCategories = [];
  List<String> _allNationalities = [];
  List<String> _allAvoids = [];
  List<String> _allAllergens = [];

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    _selectedChips = widget.ingredient != null ? [widget.ingredient!] : [];
    _fetchMealIngredients();
    loadCachedPreferences().then((data) {
      setState(() {
        _selectedAvoids.addAll(data['avoids'] ?? []);
        _selectedAllergens.addAll(data['allergens'] ?? []);
      });
    });
    _fetchIngredients();
    _fetchAllergens();
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
    final url = ApiConfig.metaCategoriesUrl;
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

  Future<void> _fetchAllergens() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final url = ApiConfig.metaAllergensUrl;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _allAllergens = List<String>.from(jsonResponse['allergen']);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _allAllergens = [];
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
    final url = ApiConfig.metaAreasUrl;

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
    final url = ApiConfig.metaIngredientsUrl;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _allIngredients = List<String>.from(jsonResponse['ingredients']);
          _allAvoids = List<String>.from(jsonResponse['ingredients']);
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _allIngredients = [];
          _allAvoids = [];
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

  Future<void> _fetchMealIngredients() async {
    final ingredientsQuery = _selectedChips.join(',');
    final nationalityQuery = _selectedNationalities.join(',');
    final cateforyyQuery = _selectedCategories.join(',');
    final avoidsQuery = _selectedAvoids.join(',');
    final allergensQuery = _selectedAllergens.join(',');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final url =
        '${ApiConfig.menuIngredientsUrl}?ingredients=$ingredientsQuery&nationality=$nationalityQuery&category=$cateforyyQuery&avoids=$avoidsQuery&allergens=$allergensQuery';
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
      } else if (response.statusCode == 400) {
        setState(() {
          _mealData = [];
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

  Future<void> _openImageSource() async {
    // Show bottom sheet with camera and gallery options
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Photo Source',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFF54AF75).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF54AF75),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Camera',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gallery',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (file == null || !mounted) return;

      final result = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(builder: (_) => ConfirmPage(imageFile: file)),
      );

      // If we got ingredients from the camera/gallery flow, add them to selected chips
      if (result != null && result.isNotEmpty) {
        setState(() {
          for (String ingredient in result) {
            if (!_selectedChips.contains(ingredient)) {
              _selectedChips.add(ingredient);
            }
          }
        });
        await _fetchMealIngredients();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${source == ImageSource.camera ? 'take picture' : 'pick image'}: $e')),
        );
      }
    }
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
          if (_mealData.isNotEmpty && !_isLoading)
            _buildMealGrid()
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Enter leftover ingredients to get recipe ideas!',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A8A8A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      forceMaterialTransparency: true,
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

            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(0xFFB6B6B6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.photo_camera, color: Colors.white, size: 28),
                    onPressed: _openImageSource,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            Stack(
              clipBehavior: Clip.none,
              children: [
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
                              selectedAllergens: _selectedAllergens,
                              selectedAvoids: _selectedAvoids,
                              selectedCategories: _selectedCategories,
                              selectedNationalities: _selectedNationalities,
                              onApply: ({
                                required List<String> allergens,
                                required List<String> avoids,
                                required List<String> categories,
                                required List<String> nationalities,
                              }) async {
                                setState(() {
                                  _selectedAllergens
                                    ..clear()
                                    ..addAll(allergens);
                                  _selectedAvoids
                                    ..clear()
                                    ..addAll(avoids);
                                  _selectedCategories
                                    ..clear()
                                    ..addAll(categories);
                                  _selectedNationalities
                                    ..clear()
                                    ..addAll(nationalities);
                                });
                                await _savePreferences(avoids, allergens);
                              },
                              fetchMealIngredients: _fetchMealIngredients,
                              fetchAllergens: _allAllergens,
                              fetchAvoids: _allAvoids,
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
                // Green Circle
                if (_selectedAllergens.isNotEmpty ||
                    _selectedAvoids.isNotEmpty ||
                    _selectedCategories.isNotEmpty ||
                    _selectedNationalities.isNotEmpty)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Icon(
                      Icons.circle,
                      color: Color(0xFF54AF75),
                      size: 15,
                    ),
                  ),
              ],
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
            await _fetchMealIngredients();
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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailPage(meal: meal)),
              );
            },
            child: custom_card.MealCard(
              strMeal: meal['strMeal'],
              strMealThumb: meal['strMealThumb'],
              strArea: meal['strArea'],
              strCategory: meal['strCategory'],
              strIngredients: _extractIngredients(meal),
            ),
          );
        }, childCount: _mealData.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 2 / 2.6,
        ),
      ),
    );
  }
}
