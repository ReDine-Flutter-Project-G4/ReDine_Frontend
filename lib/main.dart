import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/tab_bar.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/help_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReDine',
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF54AF75)),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF54AF75), // Text and Icon color
            overlayColor: Colors.black, // Hover color
            textStyle: GoogleFonts.kanit(),
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {'/': (context) => const MainHomePage()},
    );
  }
}

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          const HomeTabPage(),
          SearchTabPage(tabController: _tabController),
          const HelpTabPage(),
        ],
      ),
      bottomNavigationBar: CustomTabBar(tabController: _tabController),
    );
  }
}
