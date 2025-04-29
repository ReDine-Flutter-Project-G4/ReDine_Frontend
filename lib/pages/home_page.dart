import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../utils/card.dart' as custom_card;

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<dynamic> mockData = [];
  Future<void> loadMockData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/mock_data.json');
      final jsonResponse = json.decode(jsonString);
      setState(() {
        mockData = jsonResponse['meals'];
      });
    } catch (e) {
      print('Error loading mock data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadMockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          mockData.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(18),
                child: GridView.builder(
                  itemCount: mockData.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 2 / 2.5,
                  ),
                  itemBuilder: (context, index) {
                    final meal = mockData[index];
                    return custom_card.Card(
                      strMeal: meal['strMeal'],
                      strMealThumb: meal['strMealThumb'],
                      strArea: meal['strArea'],
                      strCategory: meal['strCategory'],
                      strIngredients: _getIngredients(meal),
                    );
                  },
                ),
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
