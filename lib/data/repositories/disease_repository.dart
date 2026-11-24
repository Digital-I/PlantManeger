import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:plantmanager/data/models/disease.dart';

/// Чтение, поиск и фильтрация болезней из каталога assets.
class DiseaseRepository {
  List<Disease>? _cache;

  Future<List<Disease>> load() async {
    if (_cache != null) return _cache!;
    final source = await rootBundle.loadString('assets/diseases_catalog.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    _cache = decoded
        .map((item) => Disease.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    return _cache!;
  }

  Future<Disease?> getById(String id) async {
    final diseases = _cache ?? await load();
    for (final disease in diseases) {
      if (disease.id == id) return disease;
    }
    return null;
  }

  Future<List<Disease>> search(String query) async {
    final diseases = _cache ?? await load();
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return List.unmodifiable(diseases);
    return diseases
        .where((disease) =>
            disease.name.toLowerCase().contains(normalizedQuery) ||
            disease.latinName.toLowerCase().contains(normalizedQuery))
        .toList();
  }

  Future<List<Disease>> byPlant(String catalogId) async {
    final diseases = _cache ?? await load();
    return diseases
        .where((disease) => disease.affectedPlantIds.contains(catalogId))
        .toList();
  }
}
