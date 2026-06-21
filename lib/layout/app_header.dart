import 'package:flutter/material.dart';

import 'package:gnps/search/suggestion_tile.dart';

class AppHeader extends StatelessWidget {
  final SearchController searchController;
  final List<Map<String, dynamic>> Function(String) onSearch;
  final void Function(Map<String, dynamic>) onWordSelected;

  const AppHeader({super.key, 
    required this.searchController,
    required this.onSearch,
    required this.onWordSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ਗੁਰੂ ਨਾਨਕ ਪੰਜਾਬੀ ਸਕੂਲ',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 4),
          Text('GNPS Dictionary', style: theme.textTheme.labelMedium),
          const SizedBox(height: 12),
          SearchAnchor(
            searchController: searchController,
            builder: (context, controller) => SearchBar(
              controller: controller,
              hintText: 'Search Punjabi or English…',
              leading: const Icon(Icons.search),
              trailing: [
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.clear,
                  ),
              ],
              onTap: controller.openView,
              onChanged: (_) => controller.openView(),
            ),
            suggestionsBuilder: (context, controller) {
              final results = onSearch(controller.text);
              if (results.isEmpty) {
                return [
                  const ListTile(
                    leading: Icon(Icons.search_off),
                    title: Text('No results found'),
                  ),
                ];
              }
              return results.map((word) => SuggestionTile(
                    word: word,
                    onTap: () {
                      controller.closeView('');
                      onWordSelected(word);
                    },
                  ));
            },
          ),
        ],
      ),
    );
  }
}
