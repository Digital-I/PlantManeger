import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantmanager/data/models/plant_info.dart';
import 'package:plantmanager/features/common/empty_state.dart';
import 'package:plantmanager/features/common/plant_avatar.dart';
import 'package:plantmanager/features/common/section_header.dart';
import 'package:plantmanager/features/common/tag_chip.dart';
import 'package:plantmanager/providers/providers.dart';

class CatalogPlantDetailScreen extends ConsumerWidget {
  const CatalogPlantDetailScreen({required this.plantId, super.key});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('О растении')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: catalog.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => EmptyState(
              icon: Icons.error_outline,
              title: 'Не удалось загрузить карточку',
              message: error.toString(),
              actionLabel: 'Повторить',
              onAction: () => ref.invalidate(catalogProvider),
            ),
            data: (items) {
              final plant =
                  items.where((item) => item.id == plantId).firstOrNull;
              if (plant == null) {
                return const EmptyState(
                  title: 'Растение не найдено',
                  message: 'Такой записи нет в каталоге.',
                );
              }
              return _CatalogPlantDetails(plant: plant);
            },
          ),
        ),
      ),
    );
  }
}

class _CatalogPlantDetails extends StatelessWidget {
  const _CatalogPlantDetails({required this.plant});

  final PlantInfo plant;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              PlantAvatar(name: plant.name, radius: 38),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plant.name,
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text(plant.latinName),
                  ],
                ),
              ),
            ],
          ),
          const SectionHeader(title: 'Описание'),
          Text(plant.description),
          const SectionHeader(title: 'Условия ухода'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              TagChip(
                label: '${plant.wateringMl.value} мл',
                icon: Icons.water_drop_outlined,
              ),
              TagChip(
                label: 'Каждые ${plant.wateringIntervalDays.value} дн.',
                icon: Icons.schedule,
              ),
              TagChip(
                label: 'Влажность ${plant.humidityPercent.value}%',
                icon: Icons.water_outlined,
              ),
              TagChip(
                label: '${plant.temperatureMinC.value}–'
                    '${plant.temperatureMaxC.value} °C',
                icon: Icons.thermostat_outlined,
              ),
            ],
          ),
          const SectionHeader(title: 'Освещение'),
          Wrap(
            spacing: 8,
            children: [
              for (final light in plant.light) TagChip(label: light.label),
            ],
          ),
          const SectionHeader(title: 'Почва'),
          Wrap(
            spacing: 8,
            children: [
              for (final soil in plant.soil) TagChip(label: soil.label),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/plants/new', extra: plant),
            icon: const Icon(Icons.add),
            label: const Text('Добавить в мои растения'),
          ),
        ],
      );
}
