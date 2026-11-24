import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantmanager/core/date_utils.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/models/plant_note.dart';
import 'package:plantmanager/features/common/confirm_dialog.dart';
import 'package:plantmanager/features/common/empty_state.dart';
import 'package:plantmanager/features/common/plant_avatar.dart';
import 'package:plantmanager/features/common/section_header.dart';
import 'package:plantmanager/features/common/tag_chip.dart';
import 'package:plantmanager/providers/providers.dart';

class PlantDetailScreen extends ConsumerWidget {
  const PlantDetailScreen({required this.plantId, super.key});
  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Растение'), actions: [
        IconButton(
          tooltip: 'Добавить заметку',
          onPressed: () => context.go('/plants/$plantId/notes/new'),
          icon: const Icon(Icons.note_add_outlined),
        ),
        IconButton(
          tooltip: 'Редактировать растение',
          onPressed: () => context.go('/plants/$plantId/edit'),
          icon: const Icon(Icons.edit_outlined),
        ),
        PopupMenuButton<String>(
          tooltip: 'Действия',
          onSelected: (action) async {
            if (action == 'diagnose') context.go('/plants/$plantId/diagnose');
            if (action == 'delete') {
              final ok = await ConfirmDialog.show(context,
                  title: 'Удалить растение?',
                  message: 'Записи журнала и поливов также будут удалены.');
              if (ok && context.mounted) {
                await ref.read(plantsProvider.notifier).delete(plantId);
                if (context.mounted) context.go('/plants');
              }
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'diagnose', child: Text('Проверить симптомы')),
            PopupMenuItem(value: 'delete', child: Text('Удалить растение')),
          ],
        ),
      ]),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: plants.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => EmptyState(
              title: 'Не удалось загрузить растение', message: error.toString(),
              actionLabel: 'Повторить', onAction: () => ref.invalidate(plantsProvider),
            ),
            data: (items) {
              final plant = items.where((p) => p.id == plantId).firstOrNull;
              if (plant == null) return const EmptyState(title: 'Растение не найдено', message: 'Оно могло быть удалено.');
              return _PlantTabs(plant: plant);
            },
          ),
        ),
      ),
    );
  }
}

class _PlantTabs extends ConsumerWidget {
  const _PlantTabs({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(plantHealthProvider(plant.id));
    return DefaultTabController(
      length: 3,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Column(children: [
            Row(children: [
              PlantAvatar(photo: plant.photo, name: plant.name, radius: 34),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(plant.name, style: Theme.of(context).textTheme.headlineSmall),
                Text(plant.species),
              ])),
            ]),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: _HealthBadge(plantId: plant.id, health: health)),
          ]),
        ),
        const TabBar(tabs: [Tab(text: 'Журнал'), Tab(text: 'Рост'), Tab(text: 'Полив')]),
        Expanded(child: TabBarView(children: [
          _JournalTab(plant: plant),
          _GrowthTab(plantId: plant.id),
          _WateringTab(plant: plant),
        ])),
      ]),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({required this.plantId, required this.health});
  final String plantId;
  final PlantHealth health;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(health.healthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          color: health.healthy ? colors.primary : colors.error),
      label: Text(health.healthy ? 'Здорово' : 'Болеет: ${health.diseases.map((d) => d.name).join(', ')}'),
      onPressed: health.healthy || health.diseases.isEmpty
          ? null
          : () => context.go('/catalog/disease/${health.diseases.first.id}'),
    );
  }
}

class _JournalTab extends ConsumerWidget {
  const _JournalTab({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(plantNotesProvider(plant.id));
    final eventList = ref.watch(diseaseEventsProvider(plant.id));
    final diseases = ref.watch(diseasesProvider).asData?.value ?? const [];
    return notes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => EmptyState(
        title: 'Не удалось загрузить журнал', message: error.toString(),
        actionLabel: 'Повторить', onAction: () => ref.invalidate(plantNotesProvider(plant.id)),
      ),
      data: (items) {
        if (items.isEmpty) return EmptyState(
          title: 'Журнал пока пуст', message: 'Добавьте первую запись о растении.',
          actionLabel: 'Добавить заметку', onAction: () => context.go('/plants/${plant.id}/notes/new'),
        );
        final records = <({DateTime date, Widget child})>[];
        for (final note in items) {
          records.add((date: note.date, child: _NoteCard(plant: plant, note: note)));
        }
        for (final event in eventList) {
          final disease = diseases.where((d) => d.id == event.diseaseId).firstOrNull;
          records.add((
            date: event.date,
            child: _DiseaseEventRow(
              label: '${event.type == DiseaseEventType.sick ? 'Заболела' : 'Вылечена'}: ${disease?.name ?? event.diseaseId}',
              sick: event.type == DiseaseEventType.sick,
            ),
          ));
        }
        records.sort((a, b) => b.date.compareTo(a.date));
        return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
          for (final record in records) record.child,
        ]);
      },
    );
  }
}

class _NoteCard extends ConsumerWidget {
  const _NoteCard({required this.plant, required this.note});
  final Plant plant;
  final PlantNote note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diseases = ref.watch(diseasesProvider).asData?.value ?? const [];
    final date = note.date;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}', style: Theme.of(context).textTheme.titleMedium)),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') context.go('/plants/${plant.id}/notes/${note.id}/edit');
                if (value == 'delete') {
                  final ok = await ConfirmDialog.show(context, title: 'Удалить запись?', message: 'Запись журнала будет удалена.');
                  if (ok) await ref.read(plantNotesProvider(plant.id).notifier).delete(note.id);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                PopupMenuItem(value: 'delete', child: Text('Удалить')),
              ],
            ),
          ]),
          if (note.photo != null) ...[
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(note.photo!, height: 160, width: double.infinity, fit: BoxFit.cover)),
          ],
          if (note.heightCm != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Высота: ${note.heightCm} см')),
          if (note.text?.isNotEmpty == true) Padding(padding: const EdgeInsets.only(top: 8), child: Text(note.text!)),
          if (note.diseaseIds.isNotEmpty) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(spacing: 6, runSpacing: 4, children: [
              for (final id in note.diseaseIds)
                TagChip(label: diseases.where((d) => d.id == id).firstOrNull?.name ?? id, icon: Icons.healing_outlined),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _DiseaseEventRow extends StatelessWidget {
  const _DiseaseEventRow({required this.label, required this.sick});
  final String label;
  final bool sick;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    child: Row(children: [Icon(sick ? Icons.sick_outlined : Icons.healing_outlined, size: 18), const SizedBox(width: 8), Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall))]),
  );
}

class _GrowthTab extends ConsumerWidget {
  const _GrowthTab({required this.plantId});
  final String plantId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(plantNotesProvider(plantId));
    final points = ref.watch(heightPointsProvider(plantId));
    return notes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => EmptyState(title: 'Не удалось загрузить журнал', message: error.toString(), actionLabel: 'Повторить', onAction: () => ref.invalidate(plantNotesProvider(plantId))),
      data: (_) => points.length < 2
          ? const EmptyState(title: 'Недостаточно данных', message: 'Добавьте высоту минимум в двух заметках.')
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: LineChart(LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        final label = value == value.roundToDouble()
                            ? value.toStringAsFixed(0)
                            : value.toStringAsFixed(1);
                        return Text(
                          label,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.labelSmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= points.length) return const SizedBox.shrink();
                    final d = points[i].date;
                    return Padding(padding: const EdgeInsets.only(top: 6), child: Text('${d.day}.${d.month}', style: Theme.of(context).textTheme.labelSmall));
                  })),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [LineChartBarData(
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].heightCm)],
                  dotData: const FlDotData(show: true),
                )],
              )),
            ),
    );
  }
}

class _WateringTab extends ConsumerWidget {
  const _WateringTab({required this.plant});
  final Plant plant;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(wateringLogsProvider);
    final today = dateOnly(DateTime.now());
    final marked = logs.asData?.value.any((log) => log.plantId == plant.id && log.done && isSameDay(log.date, today)) ?? false;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SectionHeader(title: 'Уход'),
      Wrap(spacing: 8, runSpacing: 4, children: [
        TagChip(label: 'Полив каждые ${plant.wateringIntervalDays.value} дн.', icon: Icons.water_drop_outlined),
        TagChip(label: 'Посажено ${plant.plantingDate.day}.${plant.plantingDate.month}.${plant.plantingDate.year}', icon: Icons.calendar_today_outlined),
      ]),
      const SizedBox(height: 16),
      logs.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, stack) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Не удалось загрузить отметки полива'), TextButton(onPressed: () => ref.invalidate(wateringLogsProvider), child: const Text('Повторить'))]),
        data: (_) => Card(child: ListTile(title: const Text('Полив сегодня'), trailing: FilledButton.tonal(onPressed: () => ref.read(wateringLogsProvider.notifier).toggle(plant.id, today), child: Text(marked ? 'Выполнен' : 'Отметить')))),
      ),
    ]);
  }
}
