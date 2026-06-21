import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> word;
  final List<Map<String, dynamic>> allWords;

  const ResultPage({super.key, required this.word, required this.allWords});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final meanings = word['meanings'] as List;
    final synonyms = (word['synonyms'] as List).cast<String>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _WordDetailAppBar(word: word, colorScheme: colorScheme),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _MetaRow(word: word, colorScheme: colorScheme),
                const SizedBox(height: 24),
                _DefinitionsSection(
                  meanings: meanings,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 24),
                _UsageSection(
                  meanings: meanings,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 24),
                if (synonyms.isNotEmpty) ...[
                  _SynonymsSection(
                    synonyms: synonyms,
                    allWords: allWords,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 32),
                ],
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(activeIndex: 0),
    );
  }
}

// ── Collapsing app bar ───────────────────────────────────────────────────────

class _WordDetailAppBar extends StatelessWidget {
  final Map<String, dynamic> word;
  final ColorScheme colorScheme;

  const _WordDetailAppBar({required this.word, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word['gurmukhi'] as String,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              word['roman'] as String,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorScheme.primaryContainer, colorScheme.surface],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_outline),
          tooltip: 'Save word',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.volume_up_outlined),
          tooltip: 'Pronounce',
          onPressed: () {},
        ),
      ],
    );
  }
}

// ── Part of speech + gender meta row ────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final Map<String, dynamic> word;
  final ColorScheme colorScheme;

  const _MetaRow({required this.word, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final pos = word['pos'] as String;
    final gender = word['gender'] as String?;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Badge(
          label: pos,
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
        ),
        if (gender != null)
          _Badge(
            label: gender,
            backgroundColor: colorScheme.tertiaryContainer,
            foregroundColor: colorScheme.onTertiaryContainer,
          ),
      ],
    );
  }
}

// ── Definitions section ──────────────────────────────────────────────────────

class _DefinitionsSection extends StatelessWidget {
  final List meanings;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _DefinitionsSection({
    required this.meanings,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Definitions', colorScheme: colorScheme),
        const SizedBox(height: 12),
        ...meanings.asMap().entries.map(
          (entry) => _DefinitionItem(
            index: entry.key,
            total: meanings.length,
            meaning: entry.value as Map,
            theme: theme,
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }
}

class _DefinitionItem extends StatelessWidget {
  final int index;
  final int total;
  final Map meaning;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _DefinitionItem({
    required this.index,
    required this.total,
    required this.meaning,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (total > 1)
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 12, top: 1),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: Text(
              meaning['text'] as String,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Example sentences section ────────────────────────────────────────────────

class _UsageSection extends StatelessWidget {
  final List meanings;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _UsageSection({
    required this.meanings,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final allExamples = <Map>[];
    for (final m in meanings) {
      allExamples.addAll(((m as Map)['examples'] as List).cast<Map>());
    }
    if (allExamples.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Example sentences', colorScheme: colorScheme),
        const SizedBox(height: 12),
        ...allExamples.map(
          (example) => ExampleBox(
            example: example,
            theme: theme,
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }
}

// ── Synonyms section ─────────────────────────────────────────────────────────

class _SynonymsSection extends StatelessWidget {
  final List<String> synonyms;
  final List<Map<String, dynamic>> allWords;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _SynonymsSection({
    required this.synonyms,
    required this.allWords,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(label: 'Synonyms', colorScheme: colorScheme),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: synonyms.map((s) {
            final target = allWords
                .where((w) => w['gurmukhi'] == s)
                .firstOrNull;
            return _SynonymChip(
              label: s,
              hasEntry: target != null,
              onTap: target == null
                  ? null
                  : () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ResultPage(word: target, allWords: allWords),
                      ),
                    ),
              theme: theme,
              colorScheme: colorScheme,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SynonymChip extends StatelessWidget {
  final String label;
  final bool hasEntry;
  final VoidCallback? onTap;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _SynonymChip({
    required this.label,
    required this.hasEntry,
    required this.onTap,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: hasEntry
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasEntry
                ? colorScheme.secondary
                : colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasEntry
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: hasEntry ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            if (hasEntry) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 11,
                color: colorScheme.onSecondaryContainer,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets (public so other files can reuse) ─────────────────────────

class ExampleBox extends StatelessWidget {
  final Map example;
  final ThemeData? theme;
  final ColorScheme? colorScheme;

  const ExampleBox({
    super.key,
    required this.example,
    this.theme,
    this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme ?? Theme.of(context);
    final cs = colorScheme ?? Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: cs.primary, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote, size: 14, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  'Punjabi',
                  style: t.textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              example['pun'] as String,
              style: t.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: cs.outlineVariant),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.translate, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'English',
                  style: t.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              example['eng'] as String,
              style: t.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PosBadge extends StatelessWidget {
  final String pos;
  final String? gender;

  const PosBadge({super.key, required this.pos, this.gender});

  @override
  Widget build(BuildContext context) {
    final label = gender != null ? '$pos · $gender' : pos;
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      labelStyle: Theme.of(context).textTheme.labelSmall,
      padding: EdgeInsets.zero,
    );
  }
}

class BottomNav extends StatelessWidget {
  final int activeIndex;
  const BottomNav({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: activeIndex,
      onDestinationSelected: (_) {},
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: 'Dictionary',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_outline),
          selectedIcon: Icon(Icons.bookmark),
          label: 'Saved',
        ),
        NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;

  const _SectionHeading({required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
