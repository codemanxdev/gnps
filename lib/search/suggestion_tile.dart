import 'package:flutter/material.dart';
import 'pos_badge.dart';

class SuggestionTile extends StatelessWidget {
  final Map<String, dynamic> word;
  final VoidCallback onTap;

  const SuggestionTile({super.key, required this.word, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.book_outlined),
      title: Text(
        word['gurmukhi'] as String,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        word['roman'] as String,
        style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
      ),
      trailing: PosBadge(pos: word['pos'] as String),
    );
  }
}
