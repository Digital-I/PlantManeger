import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantmanager/data/models/disease.dart';
import 'package:plantmanager/data/models/plant.dart';
import 'package:plantmanager/data/models/plant_note.dart';
import 'package:plantmanager/features/common/empty_state.dart';
import 'package:plantmanager/providers/providers.dart';
import 'package:uuid/uuid.dart';

class NoteFormScreen extends ConsumerStatefulWidget {
  const NoteFormScreen({required this.plantId, this.noteId, this.diseaseId, super.key});

  final String plantId;
  final String? noteId;
  final String? diseaseId;

  @override
  ConsumerState<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends ConsumerState<NoteFormScreen> {
  final _textController = TextEditingController();
  final _heightController = TextEditingController();
  Uint8List? _photo;
  List<String> _diseaseIds = [];
  List<String> _initialDiseaseIds = [];
  String? _initializedKey;
  bool _saving = false;

  @override
  void dispose() {
    _textController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _initialize(PlantNote? note, List<String> currentIds) {
    if (_initializedKey == widget.plantId) return;
    _initializedKey = widget.plantId;
    if (note != null) {
      _textController.text = note.text ?? '';
      _heightController.text = note.heightCm?.toString() ?? '';
      _photo = note.photo;
      _diseaseIds = [...note.diseaseIds];
      _initialDiseaseIds = [...note.diseaseIds];
    } else {
      _initialDiseaseIds = [...currentIds];
      _diseaseIds = [...currentIds];
      final preselected = widget.diseaseId;
      if (preselected != null && !_diseaseIds.contains(preselected)) {
        _diseaseIds.add(preselected);
      }
    }
  }

  bool get _hasChangesOrContent =>
      _photo != null ||
      _textController.text.trim().isNotEmpty ||
      _heightController.text.trim().isNotEmpty ||
      !_sameIds(_diseaseIds, _initialDiseaseIds);

  bool _sameIds(List<String> a, List<String> b) =>
      a.length == b.length && a.toSet().containsAll(b);

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Сделать снимок'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Выбрать фото'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 70,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _photo = bytes);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить фото: $error')),
      );
    }
  }

  Future<void> _addDisease(Plant plant, List<Disease> diseases) async {
    final search = StateProvider<String>((ref) => '');
    final selected = await showModalBottomSheet<Disease>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => ProviderScope(
        overrides: [search.overrideWith((ref) => '')],
        child: Consumer(builder: (context, sheetRef, _) {
          final query = sheetRef.watch(search).trim().toLowerCase();
          final available = diseases.where((disease) {
            if (_diseaseIds.contains(disease.id)) return false;
            return disease.name.toLowerCase().contains(query) ||
                disease.latinName.toLowerCase().contains(query);
          }).toList()
            ..sort((a, b) {
              final catalogId = plant.catalogId;
              final aMatch = catalogId != null && a.affectedPlantIds.contains(catalogId);
              final bMatch = catalogId != null && b.affectedPlantIds.contains(catalogId);
              if (aMatch != bMatch) return aMatch ? -1 : 1;
              return a.name.compareTo(b.name);
            });
          return FractionallySizedBox(
            heightFactor: 0.82,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  TextField(
                    onChanged: (value) => sheetRef.read(search.notifier).state = value,
                    decoration: const InputDecoration(
                      labelText: 'Поиск болезни',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: available.isEmpty
                        ? const Center(child: Text('Болезни не найдены'))
                        : ListView.builder(
                            itemCount: available.length,
                            itemBuilder: (context, index) {
                              final disease = available[index];
                              return ListTile(
                                title: Text(disease.name),
                                subtitle: Text(disease.latinName),
                                onTap: () => Navigator.pop(sheetContext, disease),
                              );
                            },
                          ),
                  ),
                ]),
              ),
            ),
          );
        }),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _diseaseIds = [..._diseaseIds, selected.id]);
    }
  }

  Future<void> _save(PlantNote? original, List<Disease> allDiseases) async {
    if (!_hasChangesOrContent || _saving) return;
    final heightRaw = _heightController.text.trim().replaceAll(',', '.');
    final height = heightRaw.isEmpty ? null : double.tryParse(heightRaw);
    if (heightRaw.isNotEmpty && (height == null || height < 0 || height > 1000)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Высота должна быть от 0 до 1000 см.')),
      );
      return;
    }
    final note = PlantNote(
      id: original?.id ?? const Uuid().v4(),
      plantId: widget.plantId,
      date: original?.date ?? DateTime.now(),
      photo: _photo,
      text: _textController.text.trim().isEmpty ? null : _textController.text.trim(),
      heightCm: height,
      diseaseIds: _diseaseIds,
    );
    setState(() => _saving = true);
    final notifier = ref.read(plantNotesProvider(widget.plantId).notifier);
    if (original == null) {
      await notifier.add(note);
    } else {
      await notifier.updateNote(note);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    final state = ref.read(plantNotesProvider(widget.plantId));
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить запись: ${state.error}')),
      );
      return;
    }
    if (original == null) {
      final removed = _initialDiseaseIds.toSet().difference(_diseaseIds.toSet());
      if (removed.isNotEmpty) {
        final names = removed
            .map((id) => allDiseases.where((d) => d.id == id).firstOrNull?.name ?? id)
            .join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(removed.length == _initialDiseaseIds.length
              ? 'Растение вылечено'
              : 'Вылечено: $names')),
        );
      }
    }
    context.go('/plants/${widget.plantId}');
  }

  @override
  Widget build(BuildContext context) {
    final plantState = ref.watch(plantsProvider);
    final noteState = ref.watch(plantNotesProvider(widget.plantId));
    final diseaseState = ref.watch(diseasesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.noteId == null ? 'Новая запись' : 'Изменить запись')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: plantState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => EmptyState(
              title: 'Не удалось загрузить растение', message: error.toString(),
              actionLabel: 'Повторить', onAction: () => ref.invalidate(plantsProvider),
            ),
            data: (plants) {
              final plant = plants.where((p) => p.id == widget.plantId).firstOrNull;
              if (plant == null) {
                return const EmptyState(
                  title: 'Растение не найдено',
                  message: 'Оно могло быть удалено.',
                );
              }
              return noteState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => EmptyState(
                  title: 'Не удалось загрузить журнал', message: error.toString(),
                  actionLabel: 'Повторить', onAction: () => ref.invalidate(plantNotesProvider(widget.plantId)),
                ),
                data: (notes) {
                  final original = widget.noteId == null ? null : notes.where((n) => n.id == widget.noteId).firstOrNull;
                  if (widget.noteId != null && original == null) {
                    return const EmptyState(
                      title: 'Запись не найдена',
                      message: 'Возможно, её уже удалили.',
                    );
                  }
                  _initialize(original, ref.read(currentDiseaseIdsProvider(widget.plantId)));
                  return diseaseState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => EmptyState(
                      title: 'Не удалось загрузить болезни', message: error.toString(),
                      actionLabel: 'Повторить', onAction: () => ref.invalidate(diseasesProvider),
                    ),
                    data: (diseases) => _form(plant, original, diseases),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _form(Plant plant, PlantNote? original, List<Disease> diseases) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('Дата: ${_formatDate(original?.date ?? DateTime.now())}'),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _pickPhoto,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(_photo == null ? 'Добавить фото' : 'Заменить фото'),
      ),
      if (_photo != null) ...[
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(_photo!, height: 180, fit: BoxFit.cover)),
        TextButton.icon(onPressed: () => setState(() => _photo = null), icon: const Icon(Icons.delete_outline), label: const Text('Удалить фото')),
      ],
      const SizedBox(height: 12),
      TextField(
        controller: _heightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(labelText: 'Высота, см', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _textController,
        minLines: 3,
        maxLines: 8,
        maxLength: 1000,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(labelText: 'Заметка', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 8),
      Text('Болезни', style: Theme.of(context).textTheme.titleMedium),
      Wrap(spacing: 8, children: [
        for (final id in _diseaseIds)
          InputChip(
            label: Text(diseases.where((d) => d.id == id).firstOrNull?.name ?? id),
            onDeleted: () => setState(() => _diseaseIds.remove(id)),
          ),
      ]),
      Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(
        onPressed: () => _addDisease(plant, diseases),
        icon: const Icon(Icons.add), label: const Text('Добавить болезнь'),
      )),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: _hasChangesOrContent && !_saving ? () => _save(original, diseases) : null,
        child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) : const Text('Сохранить'),
      ),
    ],
  );

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
