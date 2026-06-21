import 'package:flutter/material.dart';

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
