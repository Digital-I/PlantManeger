import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Круглое фото растения или стандартная заглушка.
class PlantAvatar extends StatelessWidget {
  const PlantAvatar({
    this.photo,
    this.name,
    this.radius = 28,
    super.key,
  });

  final Uint8List? photo;
  final String? name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primaryContainer;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      backgroundImage: photo == null ? null : MemoryImage(photo!),
      child: photo == null
          ? Text(
              name == null || name!.isEmpty ? '🌱' : name![0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}
