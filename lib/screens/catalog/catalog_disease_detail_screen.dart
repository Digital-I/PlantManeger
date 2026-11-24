import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantmanager/data/models/disease.dart';
import 'package:plantmanager/features/common/empty_state.dart';
import 'package:plantmanager/features/common/section_header.dart';
import 'package:plantmanager/features/common/tag_chip.dart';
import 'package:plantmanager/providers/providers.dart';

class CatalogDiseaseDetailScreen extends ConsumerWidget {
  const CatalogDiseaseDetailScreen({required this.diseaseId, super.key});

  final String diseaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diseases = ref.watch(diseasesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('О болезни')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: diseases.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => EmptyState(
              icon: Icons.error_outline,
              title: 'Не удалось загрузить болезнь',
              message: error.toString(),
              actionLabel: 'Повторить',
              onAction: () => ref.invalidate(diseasesProvider),
            ),
            data: (items) {
              final disease =
                  items.where((item) => item.id == diseaseId).firstOrNull;
              if (disease == null) {
                return const EmptyState(
                  title: 'Болезнь не найдена',
                  message: 'Такой записи нет в каталоге.',
                );
              }
              return _DiseaseDetails(disease: disease);
            },
          ),
        ),
      ),
    );
  }
}

class _DiseaseDetails extends StatelessWidget {
  const _DiseaseDetails({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(disease.name, style: Theme.of(context).textTheme.headlineSmall),
          Text(disease.latinName),
          const SectionHeader(title: 'Описание'),
          Text(disease.description),
          const SectionHeader(title: 'Причины'),
          for (final cause in disease.cause)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.circle, size: 10),
              title: Text(cause),
            ),
          const SectionHeader(title: 'Симптомы'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final symptom in disease.symptoms)
                TagChip(label: symptom.label),
            ],
          ),
          const SectionHeader(title: 'Лечение'),
          Text(disease.treatment),
          const SectionHeader(title: 'Тяжесть'),
          Text(disease.severity),
        ],
      );
}
