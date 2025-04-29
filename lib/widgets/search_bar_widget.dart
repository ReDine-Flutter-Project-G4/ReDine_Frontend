import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final SearchController searchController;
  final List<String> allSuggestions;
  final Function(String) onItemSelected;

  const SearchBarWidget({
    super.key,
    required this.searchController,
    required this.allSuggestions,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: searchController,
      barHintText: 'Add your ingredient',
      suggestionsBuilder: (context, controller) {
        final query = controller.text.toLowerCase();
        final suggestions = allSuggestions
            .where((item) => item.toLowerCase().contains(query))
            .toList();

        return suggestions.map((item) {
          return ListTile(
            title: Text(item),
            onTap: () {
              onItemSelected(item);
              controller.closeView(controller.text);
            },
          );
        }).toList();
      },
    );
  }
}
