import 'package:flutter/material.dart';
import 'utils/tab_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab index changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Always dispose controllers!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text('Home Page')),
          Center(child: Text('Search Page')),
          Center(child: Text('Help Page')),
        ],
      ),
      bottomNavigationBar: CustomTabBar(
        tabController: _tabController,
      ),
    );
  }
}

