import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
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
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF54AF75), // Background color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25), // Round bottom left corner
                bottomRight: Radius.circular(25), // Round bottom right corner
              ),
            ),
            child: Stack(
              children: [
                // Vegetable image - behind
                // Another image below the vegetable image
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ), // Adjust bottom margin as needed
                    child: Image.asset(
                      '../../assets/image/Intersect.png', // Replace with your new image path
                      width: 200, // Adjust size as needed
                    ),
                  ),
                ),
                // Big text - in front
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    '../../assets/image/vegetable.png',
                    fit: BoxFit.contain,
                    width: 200,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // makes column wrap its content
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // align left
                      children: [
                        Column(
                          mainAxisSize:
                              MainAxisSize
                                  .min, // Ensures the column takes up only the space it needs
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start, // Aligns the content to the left
                          children: [
                            SvgPicture.asset(
                              'assets/redine.svg',
                              height: 12,
                              width: 12,
                            ),
                            const SizedBox(
                              height: 8,
                            ), // spacing between image and text
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body:
  //         mockData.isEmpty
  //             ? const Center(child: CircularProgressIndicator())
  //             : Padding(
  //               padding: const EdgeInsets.all(18),
  //               child: GridView.builder(
  //                 itemCount: mockData.length,
  //                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                   crossAxisCount: 2,
  //                   mainAxisSpacing: 18,
  //                   crossAxisSpacing: 18,
  //                   childAspectRatio: 2 / 2.5,
  //                 ),
  //                 itemBuilder: (context, index) {
  //                   final meal = mockData[index];
  //                   return custom_card.MealCard(
  //                     strMeal: meal['strMeal'],
  //                     strMealThumb: meal['strMealThumb'],
  //                     strArea: meal['strArea'],
  //                     strCategory: meal['strCategory'],
  //                     strIngredients: _getIngredients(meal),
  //                   );
  //                 },
  //               ),
  //             ),
  //   );
  // }

  // List<String> _getIngredients(Map<String, dynamic> meal) {
  //   List<String> ingredients = [];
  //   for (int i = 1; i <= 20; i++) {
  //     if (meal['strIngredient$i'] != '' && meal['strIngredient$i'] != null) {
  //       ingredients.add('${meal['strIngredient$i']}');
  //     }
  //   }
  //   return ingredients;
  // }
