import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final String barHintText;
  final SearchController searchController;
  final List<String> allSuggestions;
  final Function(String) onItemSelected;

  const SearchBarWidget({
    super.key,
    required this.barHintText,
    required this.searchController,
    required this.allSuggestions,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 300,
      child: SearchAnchor.bar(
        viewBackgroundColor: Colors.white,
        searchController: searchController,
        barHintText: barHintText,
        barHintStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
        ),
        viewHeaderHeight: 40,
        viewHeaderTextStyle: TextStyle(fontSize: 12),
        viewHeaderHintStyle: TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
        dividerColor: Color(0xFF8A8A8A),
        isFullScreen: false,
        barBackgroundColor: WidgetStatePropertyAll(Colors.white),
        suggestionsBuilder: (context, controller) {
          final query = controller.text.toLowerCase();
          final suggestions =
              allSuggestions
                  .where((item) => item.toLowerCase().contains(query))
                  .toList();

          return suggestions.map((item) {
            return ListTile(
              title: Text(item, style: TextStyle(fontSize: 12)),
              onTap: () {
                onItemSelected(item);
                controller.closeView(controller.text);
              },
            );
          }).toList();
        },
      ),
    );
  }
}
