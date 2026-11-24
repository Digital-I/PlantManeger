import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/features/common/confirm_dialog.dart';
import 'package:plantmanager/features/common/empty_state.dart';
import 'package:plantmanager/features/common/plant_avatar.dart';
import 'package:plantmanager/features/common/section_header.dart';
import 'package:plantmanager/providers/providers.dart';

class PlantsListScreen extends ConsumerWidget {
  const PlantsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои растения'),
        actions: [
          IconButton(
            tooltip: 'Добавить растение',
            onPressed: () => context.go('/plants/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: plants.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => EmptyState(
              icon: Icons.error_outline,
              title: 'Не удалось загрузить растения',
              message: error.toString(),
              actionLabel: 'Повторить',
              onAction: () => ref.invalidate(plantsProvider),
            ),
            data: (items) => items.isEmpty
                ? EmptyState(
                    title: 'Пока здесь пусто',
                    message: 'Добавьте растение, чтобы начать уход за ним.',
                    actionLabel: 'Добавить растение',
                    onAction: () => context.go('/plants/new'),
                  )
                : _PlantList(items: items),
          ),
        ),
      ),
    );
  }
}

class _PlantList extends ConsumerWidget {
  const _PlantList({required this.items});

  final List<Plant> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          SectionHeader(title: 'Растения · ${items.length}'),
          for (final plant in items)
            Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: PlantAvatar(
                  photo: plant.photo,
                  name: plant.name,
                  radius: 26,
                ),
                title: Text(plant.name),
                subtitle: Text(
                  '${plant.species} · полив каждые '
                  '${plant.wateringIntervalDays.value} дн.',
                ),
                onTap: () => context.go('/plants/${plant.id}'),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Действия',
                  onSelected: (action) async {
                    if (action == 'open') {
                      context.go('/plants/${plant.id}');
                    } else if (action == 'delete') {
                      final confirmed = await ConfirmDialog.show(
                        context,
                        title: 'Удалить растение?',
                        message:
                            'Растение «${plant.name}» и его записи будут удалены.',
                      );
                      if (confirmed && context.mounted) {
                        await ref
                            .read(plantsProvider.notifier)
                            .delete(plant.id);
                      }
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'open', child: Text('Открыть')),
                    PopupMenuItem(value: 'delete', child: Text('Удалить')),
                  ],
                ),
              ),
            ),
        ],
      );
}
