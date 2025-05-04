import 'package:flutter/material.dart';
import 'package:redine_frontend/pages/help_page.dart';
import 'package:redine_frontend/pages/home_page.dart';
import 'package:redine_frontend/pages/search_page.dart';
import 'package:redine_frontend/widgets/tab_bar.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeTabPage(),
          SearchTabPage(tabController: _tabController),
          HelpTabPage(),
        ],
      ),
      bottomNavigationBar: CustomTabBar(tabController: _tabController),
    );
  }
}
