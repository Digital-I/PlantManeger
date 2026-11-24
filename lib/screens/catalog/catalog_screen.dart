import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantmanager/features/common/empty_state.dart';
import 'package:plantmanager/features/common/plant_avatar.dart';
import 'package:plantmanager/features/common/section_header.dart';
import 'package:plantmanager/providers/providers.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(catalogProvider);
    final diseases = ref.watch(diseasesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Каталог')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: plants.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => EmptyState(
              icon: Icons.error_outline,
              title: 'Не удалось загрузить каталог растений',
              message: error.toString(),
              actionLabel: 'Повторить',
              onAction: () => ref.invalidate(catalogProvider),
            ),
            data: (_) => diseases.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => EmptyState(
                icon: Icons.error_outline,
                title: 'Не удалось загрузить каталог болезней',
                message: error.toString(),
                actionLabel: 'Повторить',
                onAction: () => ref.invalidate(diseasesProvider),
              ),
              data: (diseaseItems) {
                final catalogItems = ref.watch(filteredCatalogProvider);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    TextField(
                      onChanged: (value) => ref
                          .read(catalogSearchProvider.notifier)
                          .state = value,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Название или латинское имя',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: ref.watch(catalogSearchProvider).isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Очистить поиск',
                                onPressed: () => ref
                                    .read(catalogSearchProvider.notifier)
                                    .state = '',
                                icon: const Icon(Icons.clear),
                              ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SectionHeader(title: 'Растения'),
                    if (catalogItems.isEmpty)
                      const EmptyState(
                        title: 'Растений не найдено',
                        message: 'Попробуйте изменить поисковый запрос.',
                      )
                    else
                      for (final plant in catalogItems)
                        Card(
                          child: ListTile(
                            leading: PlantAvatar(name: plant.name),
                            title: Text(plant.name),
                            subtitle: Text(plant.latinName),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                context.go('/catalog/plant/${plant.id}'),
                          ),
                        ),
                    const SectionHeader(title: 'Болезни'),
                    if (diseaseItems.isEmpty)
                      const EmptyState(
                        title: 'Каталог болезней пуст',
                        message: 'Справочные данные пока не добавлены.',
                        icon: Icons.healing_outlined,
                      )
                    else
                      for (final disease in diseaseItems)
                        Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.healing_outlined),
                            ),
                            title: Text(disease.name),
                            subtitle: Text(disease.latinName),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.go(
                              '/catalog/disease/${disease.id}',
                            ),
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
