import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:redine_frontend/components/profile_dropdown.dart';
import 'package:redine_frontend/components/search_bar.dart';
import 'package:redine_frontend/services/auth_service.dart';
import '../widgets/meal_card.dart' as custom_card;
import 'package:flutter_svg/flutter_svg.dart';

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
    const svgVegan = '<svg width="24" height="25" viewBox="0 0 24 25" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15 11.563C12.53 14.15 10.059 20.5 10.059 20.5C10.059 20.5 6.529 11.563 3 9.5" stroke="#8A8A8A" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M20.496 6.07692L20.922 10.5009C21.198 13.3709 19.047 15.9259 16.177 16.2029C13.361 16.4729 10.81 14.4149 10.539 11.5989C10.4742 10.9292 10.542 10.2534 10.7385 9.60991C10.9351 8.96645 11.2565 8.36805 11.6845 7.84889C12.1124 7.32974 12.6385 6.90002 13.2326 6.58431C13.8268 6.26859 14.4773 6.07307 15.147 6.00892L19.863 5.55492C19.9389 5.54761 20.0154 5.55532 20.0883 5.5776C20.1611 5.59988 20.2289 5.6363 20.2877 5.68477C20.3465 5.73325 20.3951 5.79283 20.4309 5.86012C20.4666 5.9274 20.4888 6.00108 20.496 6.07692Z" stroke="#8A8A8A" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    const svgSide = '<svg width="24" height="25" viewBox="0 0 24 25" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7 21.5H17M12 21.5C14.3869 21.5 16.6761 20.5518 18.364 18.864C20.0518 17.1761 21 14.8869 21 12.5H3C3 14.8869 3.94821 17.1761 5.63604 18.864C7.32387 20.5518 9.61305 21.5 12 21.5Z" stroke="#8A8A8A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M11.38 12.5C10.7744 12.5056 10.189 12.2821 9.74129 11.8742C9.29358 11.4663 9.01665 10.9042 8.96604 10.3006C8.91543 9.69708 9.09488 9.09672 9.4684 8.61995C9.84193 8.14318 10.3819 7.82527 10.98 7.72997C10.8843 7.3062 10.9053 6.86438 11.041 6.45164C11.1766 6.0389 11.4218 5.67072 11.7502 5.38638C12.0787 5.10203 12.4782 4.91219 12.9061 4.83709C13.3341 4.762 13.7743 4.80446 14.18 4.95997C14.3576 4.68033 14.5913 4.4405 14.8661 4.25557C15.141 4.07064 15.4512 3.94462 15.7771 3.88544C16.1031 3.82626 16.4378 3.8352 16.7601 3.91171C17.0824 3.98821 17.3854 4.13062 17.65 4.32997C18.1116 3.96719 18.6901 3.78617 19.2761 3.82116C19.8621 3.85615 20.415 4.10472 20.8301 4.51984C21.2453 4.93496 21.4938 5.48783 21.5288 6.07386C21.5638 6.65988 21.3828 7.2384 21.02 7.69997C21.2458 7.9999 21.3981 8.34862 21.4646 8.7181C21.5312 9.08758 21.5101 9.46752 21.4031 9.82738C21.2961 10.1872 21.1062 10.517 20.8486 10.7901C20.5911 11.0632 20.273 11.2721 19.92 11.4C20.0116 11.7599 20.0218 12.1356 19.95 12.5M13 12.5L17 8.49997" stroke="#8A8A8A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M10.9 7.74997C10.3515 7.16523 9.63954 6.75931 8.85697 6.58509C8.07439 6.41087 7.25748 6.47645 6.51272 6.77328C5.76796 7.0701 5.12989 7.5844 4.68169 8.24915C4.23348 8.91389 3.99593 9.69824 3.99999 10.5C3.99999 11.23 4.19999 11.91 4.53999 12.5" stroke="#8A8A8A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    const svgVege = '<svg width="24" height="25" viewBox="0 0 24 25" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M17 13.73C17 13.73 16.09 13.27 15.182 13.27C13.818 13.27 12 15.115 12 17.885C12 20.654 14.49 22.5 17 22.5C19.51 22.5 22 20.654 22 17.885C22 15.116 20.182 13.269 18.818 13.269C17.909 13.269 17 13.731 17 13.731C17 12.347 17.91 10.501 19.727 10.501M10.655 5.5C11.551 5.5 12.278 4.828 12.278 4C12.278 3.172 11.55 2.5 10.655 2.5H5.245C4.349 2.5 3.623 3.172 3.623 4C3.623 4.828 4.349 5.5 5.246 5.5M11.169 5.423C12.125 7.189 12.909 8.783 13.389 10.5C13.4283 10.64 13.4653 10.781 13.5 10.923M10.428 22.5H6.328C2.747 22.5 2 21.81 2 18.5V14.277C2 10.877 3.098 8.386 4.705 5.415" stroke="#8A8A8A" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    const svgStarter = '<svg width="24" height="25" viewBox="0 0 24 25" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 4.5C11.6835 4.72717 11.4271 5.02797 11.2528 5.37642C11.0786 5.72488 10.9918 6.1105 11 6.5C10.9918 6.8895 11.0786 7.27512 11.2528 7.62358C11.4271 7.97203 11.6835 8.27283 12 8.5M16 4.5C15.6835 4.72717 15.4271 5.02797 15.2528 5.37642C15.0786 5.72488 14.9918 6.1105 15 6.5C14.9918 6.8895 15.0786 7.27512 15.2528 7.62358C15.4271 7.97203 15.6835 8.27283 16 8.5M8 4.5C7.68351 4.72717 7.42707 5.02797 7.25285 5.37642C7.07862 5.72488 6.99184 6.1105 7 6.5C6.99184 6.8895 7.07862 7.27512 7.25285 7.62358C7.42707 7.97203 7.68351 8.27283 8 8.5M4 11.5H20C20.2652 11.5 20.5196 11.6054 20.7071 11.7929C20.8946 11.9804 21 12.2348 21 12.5V13C21 14.5 18.483 18.573 17 19.5V20.5C17 20.7652 16.8946 21.0196 16.7071 21.2071C16.5196 21.3946 16.2652 21.5 16 21.5H8C7.73478 21.5 7.48043 21.3946 7.29289 21.2071C7.10536 21.0196 7 20.7652 7 20.5V19.5C5.313 18.446 3 14.5 3 13V12.5C3 12.2348 3.10536 11.9804 3.29289 11.7929C3.48043 11.6054 3.73478 11.5 4 11.5Z" stroke="#8A8A8A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    const svgMis = '<svg width="24" height="25" viewBox="0 0 24 25" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15.5 7C15.5 7.45963 15.4095 7.91475 15.2336 8.33939C15.0577 8.76403 14.7999 9.14987 14.4749 9.47487C14.1499 9.79988 13.764 10.0577 13.3394 10.2336C12.9148 10.4095 12.4596 10.5 12 10.5C11.5404 10.5 11.0852 10.4095 10.6606 10.2336C10.236 10.0577 9.85013 9.79988 9.52513 9.47487C9.20012 9.14987 8.94231 8.76403 8.76642 8.33939C8.59053 7.91475 8.5 7.45963 8.5 7C8.5 6.07174 8.86875 5.1815 9.52513 4.52513C10.1815 3.86875 11.0717 3.5 12 3.5C12.9283 3.5 13.8185 3.86875 14.4749 4.52513C15.1313 5.1815 15.5 6.07174 15.5 7ZM22 18C22 18.9283 21.6313 19.8185 20.9749 20.4749C20.3185 21.1313 19.4283 21.5 18.5 21.5C17.5717 21.5 16.6815 21.1313 16.0251 20.4749C15.3687 19.8185 15 18.9283 15 18C15 17.0717 15.3687 16.1815 16.0251 15.5251C16.6815 14.8687 17.5717 14.5 18.5 14.5C19.4283 14.5 20.3185 14.8687 20.9749 15.5251C21.6313 16.1815 22 17.0717 22 18ZM9 18C9 18.4596 8.90947 18.9148 8.73358 19.3394C8.55769 19.764 8.29988 20.1499 7.97487 20.4749C7.64987 20.7999 7.26403 21.0577 6.83939 21.2336C6.41475 21.4095 5.95963 21.5 5.5 21.5C5.04037 21.5 4.58525 21.4095 4.16061 21.2336C3.73597 21.0577 3.35013 20.7999 3.02513 20.4749C2.70012 20.1499 2.44231 19.764 2.26642 19.3394C2.09053 18.9148 2 18.4596 2 18C2 17.0717 2.36875 16.1815 3.02513 15.5251C3.6815 14.8687 4.57174 14.5 5.5 14.5C6.42826 14.5 7.3185 14.8687 7.97487 15.5251C8.63125 16.1815 9 17.0717 9 18Z" stroke="#8A8A8A" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';
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
      {'icon': Iconify(svgStarter, size: 30), 'label': 'Starter'},
      {'icon': Iconify(svgSide, size: 30), 'label': 'Side'},
      {'icon': Iconify(svgVege, size: 30), 'label': 'Vegetarian'},
      {'icon': Iconify(svgVegan, size: 35), 'label': 'Vegan'},
      {'icon': Iconify(svgMis, size: 30), 'label': 'Miscellaneous'},
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
