import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/models/plant_info.dart';
import 'package:plantmanager/data/value_objects/watering_interval_days_vo.dart';
import 'package:plantmanager/features/common/empty_state.dart';
import 'package:plantmanager/features/common/tag_chip.dart';
import 'package:plantmanager/providers/providers.dart';
import 'package:uuid/uuid.dart';

class PlantFormScreen extends ConsumerStatefulWidget {
  const PlantFormScreen({this.plantId, this.initialCatalogPlant, super.key});

  final String? plantId;
  final PlantInfo? initialCatalogPlant;

  @override
  ConsumerState<PlantFormScreen> createState() => _PlantFormScreenState();
}

class _PlantFormScreenState extends ConsumerState<PlantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _intervalController = TextEditingController();
  String? _initializedKey;
  String? _catalogId;
  PlantInfo? _selectedCatalogPlant;
  bool _intervalManuallyChanged = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _initialize(Plant? plant) {
    final key =
        '${widget.plantId ?? 'new'}:${widget.initialCatalogPlant?.id ?? ''}';
    if (_initializedKey == key) return;
    _initializedKey = key;
    _intervalManuallyChanged = false;
    if (plant != null) {
      _nameController.text = plant.name;
      _speciesController.text = plant.species;
      _intervalController.text = '${plant.wateringIntervalDays.value}';
      _catalogId = plant.catalogId;
      return;
    }

    _intervalController.text = '7';
    final catalogPlant = widget.initialCatalogPlant;
    if (catalogPlant != null) {
      _applyInitialCatalogPlant(catalogPlant);
    }
  }

  void _applyInitialCatalogPlant(PlantInfo plant) {
    _catalogId = plant.id;
    _selectedCatalogPlant = plant;
    _speciesController.text = '${plant.name} (${plant.latinName})';
    _nameController.text = plant.name;
    _intervalController.text = '${plant.wateringIntervalDays.value}';
  }

  Future<void> _chooseCatalogPlant() async {
    ref.read(catalogSearchProvider.notifier).state = '';
    final plant = await showModalBottomSheet<PlantInfo>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (context, sheetRef, child) {
          final catalog = sheetRef.watch(catalogProvider);
          return FractionallySizedBox(
            heightFactor: 0.85,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Выберите вид',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: false,
                      onChanged: (value) => sheetRef
                          .read(catalogSearchProvider.notifier)
                          .state = value,
                      decoration: const InputDecoration(
                        labelText: 'Поиск по каталогу',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: catalog.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) => EmptyState(
                          icon: Icons.error_outline,
                          title: 'Не удалось загрузить каталог',
                          message: error.toString(),
                          actionLabel: 'Повторить',
                          onAction: () => sheetRef.invalidate(catalogProvider),
                        ),
                        data: (_) {
                          final plants =
                              sheetRef.watch(filteredCatalogProvider);
                          if (plants.isEmpty) {
                            return const EmptyState(
                              title: 'Ничего не найдено',
                              message: 'Измените поисковый запрос.',
                            );
                          }
                          return ListView.builder(
                            itemCount: plants.length,
                            itemBuilder: (context, index) {
                              final plant = plants[index];
                              return Card(
                                child: ListTile(
                                  title: Text(plant.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(plant.latinName),
                                      if (plant.light.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 4,
                                          runSpacing: 2,
                                          children: [
                                            for (final light in plant.light)
                                              TagChip(label: light.label),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        '${plant.wateringMl.value} мл раз в '
                                        '${plant.wateringIntervalDays.value} дн.',
                                      ),
                                    ],
                                  ),
                                  onTap: () =>
                                      Navigator.of(sheetContext).pop(plant),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (plant != null) await _selectCatalogPlant(plant);
  }

  Future<void> _selectCatalogPlant(PlantInfo plant) async {
    var replaceInterval = !_intervalManuallyChanged;
    if (_intervalManuallyChanged) {
      replaceInterval = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Заменить интервал полива?'),
              content: Text(
                'Заменить интервал полива на '
                '${plant.wateringIntervalDays.value} дней?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Оставить текущий'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Заменить'),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (!mounted) return;

    setState(() {
      _catalogId = plant.id;
      _selectedCatalogPlant = plant;
      _speciesController.text = '${plant.name} (${plant.latinName})';
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = plant.name;
      }
      if (replaceInterval) {
        _intervalController.text = '${plant.wateringIntervalDays.value}';
      }
    });
  }

  Widget _catalogPickerCard(PlantInfo? selectedPlant) {
    if (selectedPlant == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_florist_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Вид из каталога: ${selectedPlant.name}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _catalogId = null;
                    _selectedCatalogPlant = null;
                  }),
                  child: const Text('Сбросить'),
                ),
              ],
            ),
            Text(selectedPlant.latinName),
          ],
        ),
      ),
    );
  }

  Future<void> _save(Plant? original) async {
    if (!_formKey.currentState!.validate()) return;
    final interval = int.parse(_intervalController.text.trim());
    final now = DateTime.now();
    final plant = original == null
        ? Plant(
            id: const Uuid().v4(),
            name: _nameController.text.trim(),
            species: _speciesController.text.trim(),
            createdAt: now,
            plantingDate: now,
            wateringIntervalDays: WateringIntervalDaysVo(interval),
            catalogId: _catalogId,
          )
        : original.copyWith(
            name: _nameController.text.trim(),
            species: _speciesController.text.trim(),
            wateringIntervalDays: WateringIntervalDaysVo(interval),
            catalogId: _catalogId,
            clearCatalogId: _catalogId == null,
          );

    setState(() => _saving = true);
    if (original == null) {
      await ref.read(plantsProvider.notifier).add(plant);
    } else {
      await ref.read(plantsProvider.notifier).updatePlant(plant);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    final currentState = ref.read(plantsProvider);
    if (currentState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentState.error.toString())),
      );
      return;
    }
    context.go('/plants/${plant.id}');
  }

  @override
  Widget build(BuildContext context) {
    final plants = ref.watch(plantsProvider);
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plantId == null
            ? 'Новое растение'
            : 'Редактирование растения'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: plants.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => EmptyState(
              icon: Icons.error_outline,
              title: 'Не удалось загрузить растение',
              message: error.toString(),
              actionLabel: 'Повторить',
              onAction: () => ref.invalidate(plantsProvider),
            ),
            data: (items) {
              final original = widget.plantId == null
                  ? null
                  : items
                      .where((item) => item.id == widget.plantId)
                      .firstOrNull;
              if (widget.plantId != null && original == null) {
                return const EmptyState(
                  title: 'Растение не найдено',
                  message: 'Возможно, оно было удалено.',
                );
              }
              _initialize(original);
              return catalog.when(
                loading: () => _form(
                  original,
                  catalogPlants: const [],
                  catalogLoading: true,
                ),
                error: (error, stackTrace) => _form(
                  original,
                  catalogPlants: const [],
                  catalogError: error,
                ),
                data: (catalogPlants) => _form(
                  original,
                  catalogPlants: catalogPlants,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _form(
    Plant? original, {
    required List<PlantInfo> catalogPlants,
    bool catalogLoading = false,
    Object? catalogError,
  }) {
    final selectedPlant = _selectedCatalogPlant ??
        catalogPlants.where((plant) => plant.id == _catalogId).firstOrNull;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Название'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Введите название растения'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _speciesController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Вид',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) {
              if (_catalogId != null) {
                setState(() {
                  _catalogId = null;
                  _selectedCatalogPlant = null;
                });
              }
            },
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Укажите вид растения'
                : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _chooseCatalogPlant,
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Выбрать из каталога'),
            ),
          ),
          if (catalogLoading) ...[
            const SizedBox(height: 4),
            const LinearProgressIndicator(),
          ],
          if (catalogError != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.error_outline),
                title: const Text('Каталог временно недоступен'),
                subtitle: Text(catalogError.toString()),
                trailing: IconButton(
                  tooltip: 'Повторить',
                  onPressed: () => ref.invalidate(catalogProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ),
          _catalogPickerCard(selectedPlant),
          const SizedBox(height: 16),
          TextFormField(
            controller: _intervalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Интервал полива',
              suffixText: 'дней',
            ),
            onChanged: (_) => _intervalManuallyChanged = true,
            validator: (value) {
              final interval = int.tryParse(value?.trim() ?? '');
              return interval == null || interval <= 0
                  ? 'Введите положительное число дней'
                  : null;
            },
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : () => _save(original),
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(original == null
                ? 'Сохранить растение'
                : 'Сохранить изменения'),
          ),
        ],
      ),
    );
  }
}
