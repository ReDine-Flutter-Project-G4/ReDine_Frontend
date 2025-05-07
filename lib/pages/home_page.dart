import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:redine_frontend/components/profile_dropdown.dart';
import 'package:redine_frontend/components/search_bar.dart';
import 'package:redine_frontend/pages/search_page.dart';
import 'package:redine_frontend/services/auth_service.dart';
import '../widgets/meal_card.dart' as custom_card;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

// Iconify
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/fluent_emoji_high_contrast.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/ep.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:iconify_flutter/icons/game_icons.dart';
import 'package:iconify_flutter/icons/icon_park_solid.dart';
import 'package:iconify_flutter/icons/ph.dart';

class HomeTabPage extends StatefulWidget {
  final TabController tabController;
  final void Function(String ingredient) onIngredientSelected;
  const HomeTabPage({
    super.key,
    required this.tabController,
    required this.onIngredientSelected,
  });

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  static const String baseUrl = 'http://localhost:3000/api';
  List<dynamic> mealData = [];
  bool _isLoading = true;
  bool _isMenuLoading = true;
  String _errorMessage = '';
  List<String> _allIngredients = [];
  late final SearchController _searchController;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    selectedCategory = 'Beef';
    fetchMeals(category: selectedCategory); // Load all meals on start
    _fetchIngredients();
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

  Future<void> _fetchIngredients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final url = '$baseUrl/meta/ingredients';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _allIngredients = List<String>.from(jsonResponse['ingredients']);
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _allIngredients = [];
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

  Future<void> fetchMeals({String? category}) async {
    setState(() {
      _isMenuLoading = true;
    });

    final categoryQuery = category != null ? '&category=$category' : '';
    final url = '$baseUrl/menu/ingredients?$categoryQuery';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          mealData = jsonResponse['meals'];
          _isMenuLoading = false;
        });
      } else {
        setState(() {
          mealData = [];
          _isMenuLoading = false;
        });
      }
    } catch (e) {
      print('Error loading mock data: $e');
      _isMenuLoading = false;
    }
  }

  void onCategorySelected(String? categoryLabel) {
    setState(() {
      selectedCategory = categoryLabel ?? '';
    });
    fetchMeals(category: categoryLabel);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
            top: 10,
            bottom: 5,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Discover new recipes',
              style: GoogleFonts.livvic(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: HorizontalIconRow(
            selectedCategory: selectedCategory,
            onCategoryTap: onCategorySelected,
          ),
        ),
        if (_isMenuLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (mealData.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text("No meals found.")),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final meal = mealData[index];
                return custom_card.MealCard(
                  strMeal: meal['strMeal'],
                  strMealThumb: meal['strMealThumb'],
                  strArea: meal['strArea'],
                  strCategory: meal['strCategory'],
                  strIngredients: _extractIngredients(meal),
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
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 230,
      title: Transform.translate(
        offset: const Offset(0, -15),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            color: Color(0xFF54AF75),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Image.asset('assets/image/Intersect.png', width: 200),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Transform.translate(
                  offset: const Offset(0, 20),
                  child: Image.asset(
                    'assets/image/vegetable.png',
                    fit: BoxFit.contain,
                    width: 200,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/redine.svg',
                            height: 12,
                            width: 12,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cook from\nyour leftover!',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () async {
                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        final position = button.localToGlobal(
                          Offset(button.size.width, 90),
                        );
                        ProfileDropdown.show(context, position);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black12,
                          child: ClipOval(
                            child: AuthService().getProfileImage(size: 60),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: -20,
                    left: 16,
                    right: 16,
                    child: SearchBarWidget(
                      barHintText: 'Add your ingredient',
                      searchController: _searchController,
                      allSuggestions: _allIngredients,
                      onItemSelected: (item) async {
                        widget.onIngredientSelected(item);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HorizontalIconRow extends StatelessWidget {
  final String selectedCategory;
  final Function(String?) onCategoryTap;

  const HorizontalIconRow({
    super.key,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Iconify(Mdi.cow, size: 35), 'label': 'Beef'},
      {
        'icon': Iconify(FluentEmojiHighContrast.chicken, size: 30),
        'label': 'Chicken',
      },
      {
        'icon': Iconify(FluentEmojiHighContrast.pig_face, size: 30),
        'label': 'Pork',
      },
      {'icon': Iconify(Mdi.sheep, size: 33), 'label': 'Lamb'},
      {
        'icon': Iconify(FluentEmojiHighContrast.goat, size: 30),
        'label': 'Goat',
      },
      {'icon': Iconify(Ion.fish, size: 30), 'label': 'Seafood'},
      {'icon': Iconify(Mdi.pasta, size: 35), 'label': 'Pasta'},
      {'icon': Iconify(Ep.dessert, size: 30), 'label': 'Dessert'},
      {
        'icon': Iconify(MaterialSymbols.wb_sunny, size: 30),
        'label': 'Breakfast',
      },
      {'icon': Iconify(Tabler.soup, size: 30), 'label': 'Starter'},
      {'icon': Iconify(GameIcons.dumpling, size: 30), 'label': 'Side'},
      {'icon': Iconify(IconParkSolid.milk, size: 30), 'label': 'Vegetarian'},
      {'icon': Iconify(Ph.leaf_bold, size: 30), 'label': 'Vegan'},
      {'icon': Iconify(Ep.more, size: 30), 'label': 'Miscellaneous'},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final rawCategory = categories[index];
          final label = rawCategory['label'] as String;
          final isSelected = label == selectedCategory;

          // Rebuild the icon with dynamic color
          final icon = Iconify(
            (rawCategory['icon'] as Iconify).icon,
            size: (rawCategory['icon'] as Iconify).size,
            color: isSelected ? Colors.white : Color(0xFF8A8A8A),
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                onCategoryTap(isSelected ? null : label); // Deselect if same
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          isSelected ? Color(0xFF54AF75) : Colors.white,
                      child: IconTheme(
                        data: IconThemeData(
                          color: isSelected ? Colors.white : Color(0xFF8A8A8A),
                        ),
                        child: icon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
