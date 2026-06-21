import 'package:flutter/material.dart';

import '../data/dictionary_data.dart';
import '../layout/app_header.dart';
import '../layout/bottom_navigation.dart';
import '../result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchController _searchController = SearchController();
  String _activeFilter = 'all';

  static const _filters = ['all', 'noun', 'verb', 'adjective', 'phrase'];

  List<Map<String, dynamic>> get _filteredWords {
    if (_activeFilter == 'all') return DictionaryData.words;
    return DictionaryData.words
        .where((w) => w['pos'] == _activeFilter)
        .toList();
  }

  List<Map<String, dynamic>> _search(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return DictionaryData.words.where((w) {
      if ((w['gurmukhi'] as String).contains(query)) return true;
      if ((w['roman'] as String).toLowerCase().contains(q)) return true;
      final meanings = w['meanings'] as List;
      if (meanings.any((m) => (m['text'] as String).toLowerCase().contains(q))) {
        return true;
      }
      final synonyms = w['synonyms'] as List;
      if (synonyms.any((s) => (s as String).contains(query))) return true;
      return false;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              searchController: _searchController,
              onSearch: _search,
              onWordSelected: (word) => _navigateToDetail(context, word),
            ),
            _FilterChips(
              filters: _filters,
              activeFilter: _activeFilter,
              onFilterChanged: (filter) =>
                  setState(() => _activeFilter = filter),
            ),
            Expanded(
              child: _WordList(
                words: _filteredWords,
                onWordTap: (word) => _navigateToDetail(context, word),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(activeIndex: 0),
    );
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(word: word, allWords: DictionaryData.words),
      ),
    );
  }
}

// ── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final List<String> filters;
  final String activeFilter;
  final void Function(String) onFilterChanged;

  const _FilterChips({
    required this.filters,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  String _label(String filter) => filter == 'all'
      ? 'All'
      : '${filter[0].toUpperCase()}${filter.substring(1)}s';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: filters.map((filter) {
          final active = filter == activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_label(filter)),
              selected: active,
              onSelected: (_) => onFilterChanged(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Word list ────────────────────────────────────────────────────────────────

class _WordList extends StatelessWidget {
  final List<Map<String, dynamic>> words;
  final void Function(Map<String, dynamic>) onWordTap;

  const _WordList({required this.words, required this.onWordTap});

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Center(child: Text('No words found'));
    }

    // Group by first Gurmukhi character
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final word in words) {
      final gurmukhi = word['gurmukhi'] as String;
      if (gurmukhi.isNotEmpty) {
        final letter = gurmukhi[0];
        groups.putIfAbsent(letter, () => []).add(word);
      }
    }

    final sections = groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      itemCount: sections.fold<int>(0, (sum, e) => sum + 1 + e.value.length),
      itemBuilder: (context, index) {
        int cursor = 0;
        for (final section in sections) {
          if (index == cursor) {
            return _SectionHeader(letter: section.key);
          }
          cursor++;
          final wordIndex = index - cursor;
          if (wordIndex >= 0 && wordIndex < section.value.length) {
            return _WordCard(
              word: section.value[wordIndex],
              onTap: () => onWordTap(section.value[wordIndex]),
            );
          }
          cursor += section.value.length;
        }
        return null;
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String letter;
  const _SectionHeader({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        letter,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 0.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final Map<String, dynamic> word;
  final VoidCallback onTap;

  const _WordCard({required this.word, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meanings = word['meanings'] as List;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word['gurmukhi'] as String,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              word['roman'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            PosBadge(
              pos: word['pos'] as String,
              gender: word['gender'] as String?,
            ),
            const SizedBox(height: 6),
            if (meanings.isNotEmpty)
              Text(
                meanings[0]['text'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
