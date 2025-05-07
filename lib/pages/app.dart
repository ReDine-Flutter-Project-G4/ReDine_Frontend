import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redine_frontend/pages/help_page.dart';
import 'package:redine_frontend/pages/home_page.dart';
import 'package:redine_frontend/pages/search_page.dart';
import 'package:redine_frontend/widgets/tab_bar.dart';
import 'package:redine_frontend/state/global_flags.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedIngredient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (GlobalFlags.isNewUser) {
        GlobalFlags.isNewUser = false; // reset
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  'Welcome!',
                  style: GoogleFonts.livvic(fontWeight: FontWeight.w700),
                ),
                content: const Text('Your account was successfully created.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF54AF75),
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
        );
      }
    });
  }

  void updateIngredient(String ingredient) {
    setState(() {
      selectedIngredient = ingredient;
    });
    _tabController.animateTo(1); // Go to search tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeTabPage(
            tabController: _tabController,
            onIngredientSelected: updateIngredient,
          ),
          SearchTabPage(
            key: ValueKey(selectedIngredient),
            tabController: _tabController,
            ingredient: selectedIngredient,
          ),
          HelpTabPage(),
        ],
      ),
      bottomNavigationBar: CustomTabBar(tabController: _tabController),
    );
  }
}
