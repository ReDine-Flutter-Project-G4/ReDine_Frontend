import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:redine_frontend/components/profile_dropdown.dart';
import 'package:redine_frontend/components/search_bar.dart';
import 'package:redine_frontend/pages/search_page.dart';
import 'package:redine_frontend/services/auth_service.dart';
import '../widgets/meal_card.dart' as custom_card;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';

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
  List<dynamic> mockData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  List<String> _allIngredients = [];
  late final SearchController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    loadMockData();
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

  Future<void> loadMockData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/mock_data.json');
      final jsonResponse = json.decode(jsonString);
      setState(() {
        mockData = jsonResponse['meals'];
      });
      _isLoading = false;
    } catch (e) {
      print('Error loading mock data: $e');
      _isLoading = false;
    }
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
          padding: const EdgeInsets.all(18),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final meal = mockData[index];
              return custom_card.MealCard(
                strMeal: meal['strMeal'],
                strMealThumb: meal['strMealThumb'],
                strArea: meal['strArea'],
                strCategory: meal['strCategory'],
                strIngredients: _extractIngredients(meal),
              );
            }, childCount: mockData.length),
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
