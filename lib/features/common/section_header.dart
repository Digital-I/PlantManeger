import 'package:flutter/material.dart';

/// Заголовок раздела с необязательным действием справа.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}
