import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/meal_card.dart' as custom_card;
import '../widgets/tab_bar.dart';
import '../pages/search_page.dart';
import '../pages/help_page.dart';
import '../services/auth_service.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> mockData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes (to show/hide logout)
    });
    loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadMockData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/mock_data.json');
      final jsonResponse = json.decode(jsonString);
      setState(() {
        mockData = jsonResponse['meals'];
      });
    } catch (e) {
      print('Error loading mock data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeWithSliverAppBar(),
          SearchTabPage(tabController: _tabController),
          const HelpTabPage(),
        ],
      ),
      bottomNavigationBar: CustomTabBar(tabController: _tabController),
    );
  }

  Widget _buildHomeWithSliverAppBar() {
    return mockData.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
          slivers: [
            SliverAppBar(
              // expandedHeight: 100,
              floating: true,
              snap: true,
              forceMaterialTransparency: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await AuthService().signOut();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
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
                    strIngredients: _getIngredients(meal),
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

  List<String> _getIngredients(Map<String, dynamic> meal) {
    return [
      for (int i = 1; i <= 20; i++)
        if ((meal['strIngredient$i'] ?? '').toString().trim().isNotEmpty)
          meal['strIngredient$i'].toString(),
    ];
  }
}
