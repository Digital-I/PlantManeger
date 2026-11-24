import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantmanager/features/common/empty_state.dart';
import 'package:plantmanager/features/common/plant_avatar.dart';
import 'package:plantmanager/features/common/section_header.dart';
import 'package:plantmanager/features/common/tag_chip.dart';
import 'package:plantmanager/providers/providers.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    final logs = ref.watch(wateringLogsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Сегодня')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: plants.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _loadError(
              error,
              () => ref.invalidate(plantsProvider),
            ),
            data: (items) => logs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _loadError(
                error,
                () => ref.invalidate(wateringLogsProvider),
              ),
              data: (_) => items.isEmpty
                  ? EmptyState(
                      title: 'Добавьте первое растение',
                      message: 'После этого здесь появятся задачи по уходу.',
                      actionLabel: 'К растениям',
                      onAction: () => context.go('/plants'),
                    )
                  : _tasks(context, ref),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadError(Object error, VoidCallback retry) => EmptyState(
        icon: Icons.error_outline,
        title: 'Не удалось загрузить задачи',
        message: error.toString(),
        actionLabel: 'Повторить',
        onAction: retry,
      );

  Widget _tasks(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todayTasksProvider);
    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'На сегодня всё готово',
        message: 'Нет растений, которым требуется полив.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        SectionHeader(title: 'Полив · ${tasks.length}'),
        for (final task in tasks)
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: PlantAvatar(
                photo: task.plant.photo,
                name: task.plant.name,
              ),
              title: Text(task.plant.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.plant.species),
                  const SizedBox(height: 4),
                  TagChip(
                    label: task.overdue ? 'Просрочено' : 'Сегодня',
                    icon: task.overdue
                        ? Icons.warning_amber_outlined
                        : Icons.water_drop_outlined,
                  ),
                ],
              ),
              onTap: () => context.go('/plants/${task.plant.id}'),
              trailing: IconButton.filledTonal(
                tooltip: 'Отметить полив выполненным',
                onPressed: () => ref
                    .read(wateringLogsProvider.notifier)
                    .markDone(task.plant.id, DateTime.now()),
                icon: const Icon(Icons.check),
              ),
            ),
          ),
      ],
    );
  }
}
