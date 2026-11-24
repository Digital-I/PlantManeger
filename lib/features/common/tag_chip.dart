import 'package:flutter/material.dart';

/// Компактная метка для статусов и характеристик.
class TagChip extends StatelessWidget {
  const TagChip({required this.label, this.icon, super.key});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: icon == null ? null : Icon(icon, size: 16),
        label: Text(label),
        visualDensity: VisualDensity.compact,
      );
}
