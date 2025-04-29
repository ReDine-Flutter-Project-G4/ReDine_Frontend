import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/chip_list_widget.dart';
import '../widgets/filter_bottom_sheet.dart';

class SearchTabPage extends StatefulWidget {
  final TabController tabController;
  const SearchTabPage({super.key, required this.tabController});

  @override
  State<SearchTabPage> createState() => _SearchTabPageState();
}

class _SearchTabPageState extends State<SearchTabPage> {
  late final SearchController _searchController;
  final List<String> allSuggestions = [
    'Chicken Breast',
    'Chicken Thighs',
    'Pork Belly',
    'Beef Ribs',
  ];
  final List<String> _selectedChips = [];

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            floating: true,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            toolbarHeight: 70,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 24,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      widget.tabController.animateTo(0);
                    },
                  ),

                  const SizedBox(width: 8),

                  // SearchAnchor
                  Expanded(
                    child: SearchBarWidget(
                      searchController: _searchController,
                      allSuggestions: allSuggestions,
                      onItemSelected: (item) {
                        setState(() {
                          if (!_selectedChips.contains(item)) {
                            _selectedChips.add(item);
                          }
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Filter Button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB6B6B6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => const FilterBottomSheet(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_selectedChips.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ChipListWidget(
                  chips: _selectedChips,
                  onChipDeleted: (chip) {
                    setState(() {
                      _selectedChips.remove(chip);
                    });
                  },
                ),
              ),
            ),

          // Page Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(height: 1000, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
