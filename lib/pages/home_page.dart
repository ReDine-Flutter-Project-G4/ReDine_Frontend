import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redine_frontend/services/auth_service.dart';
import '../widgets/meal_card.dart' as custom_card;
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMockData();
  }

  Future<void> loadMockData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/mock_data.json');
      final jsonResponse = json.decode(jsonString);
      setState(() {
        mockData = jsonResponse['meals'];
      });
      isLoading = false;
    } catch (e) {
      print('Error loading mock data: $e');
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 200,
      title: Container(
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
            // Vegetable image - behind
            // Another image below the vegetable image
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                ), // Adjust bottom margin as needed
                child: Image.asset(
                  'assets/image/Intersect.png', // Replace with your new image path
                  width: 200, // Adjust size as needed
                ),
              ),
            ),
            // Big text - in front
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                'assets/image/vegetable.png',
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
                  crossAxisAlignment: CrossAxisAlignment.start, // align left
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
                      _showProfileMenu(context, position);
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
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(child: AuthService().getProfileImage(size: 40)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AuthService().getUserName(),
                            style: GoogleFonts.livvic(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            softWrap: true,
                          ),
                          Text(
                            AuthService().getUserEmail(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('Confirm Logout'),
                            content: const Text(
                              'Are you sure you want to log out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                ),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xFF54AF75),
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                    );
                    if (shouldLogout == true) {
                      await AuthService().signOut();
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Log Out', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
