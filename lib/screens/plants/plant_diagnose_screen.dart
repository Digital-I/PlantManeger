import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/models/symptom_enum.dart';
import 'package:plantmanager/features/common/empty_state.dart';
import 'package:plantmanager/features/common/section_header.dart';
import 'package:plantmanager/providers/providers.dart';

class PlantDiagnoseScreen extends ConsumerStatefulWidget {
  const PlantDiagnoseScreen({required this.plantId, super.key});

  final String plantId;

  @override
  ConsumerState<PlantDiagnoseScreen> createState() =>
      _PlantDiagnoseScreenState();
}

class _PlantDiagnoseScreenState extends ConsumerState<PlantDiagnoseScreen> {
  final Set<Symptom> _selected = {};

  @override
  Widget build(BuildContext context) {
    final plants = ref.watch(plantsProvider);
    final diseases = ref.watch(diseasesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Диагностика')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: plants.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _error(
              error,
              () => ref.invalidate(plantsProvider),
            ),
            data: (plantItems) {
              final plant = plantItems
                  .where((item) => item.id == widget.plantId)
                  .firstOrNull;
              if (plant == null) {
                return const EmptyState(
                  title: 'Растение не найдено',
                  message: 'Возможно, оно было удалено.',
                );
              }
              return diseases.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _error(
                  error,
                  () => ref.invalidate(diseasesProvider),
                ),
                data: (items) => _diagnosis(plant),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _error(Object error, VoidCallback retry) => EmptyState(
        icon: Icons.error_outline,
        title: 'Не удалось загрузить данные',
        message: error.toString(),
        actionLabel: 'Повторить',
        onAction: retry,
      );

  Widget _diagnosis(Plant plant) {
    final results = ref.watch(
      diagnosisProvider((plant: plant, selected: Set<Symptom>.of(_selected))),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Выберите симптомы у растения «${plant.name}».',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SectionHeader(title: 'Симптомы'),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final symptom in Symptom.values)
              FilterChip(
                label: Text(symptom.label),
                selected: _selected.contains(symptom),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _selected.add(symptom);
                  } else {
                    _selected.remove(symptom);
                  }
                }),
              ),
          ],
        ),
        SectionHeader(
          title: 'Возможные причины · ${results.length}',
          trailing: IconButton(
            tooltip: 'Очистить симптомы',
            onPressed:
                _selected.isEmpty ? null : () => setState(_selected.clear),
            icon: const Icon(Icons.clear_all),
          ),
        ),
        if (_selected.isEmpty)
          const EmptyState(
            title: 'Выберите симптомы',
            message: 'Подходящие болезни появятся в этом разделе.',
            icon: Icons.search,
          )
        else if (results.isEmpty)
          const EmptyState(
            title: 'Совпадений не найдено',
            message: 'Попробуйте выбрать другие симптомы.',
            icon: Icons.check_circle_outline,
          )
        else
          for (final result in results)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      child: Text('${(result.$2 * 100).round()}%'),
                    ),
                    title: Text(result.$1.name),
                    subtitle: Text(
                      '${result.$1.latinName}\n'
                      'Совпадение симптомов: '
                      '${(result.$2 * 100).round()}%',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/catalog/disease/${result.$1.id}'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.go(
                        '/plants/${plant.id}/notes/new',
                        extra: result.$1.id,
                      ),
                      icon: const Icon(Icons.note_add_outlined),
                      label: const Text('Добавить в заметку'),
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go('/plants/${plant.id}'),
          icon: const Icon(Icons.arrow_back),
          label: const Text('К растению'),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
