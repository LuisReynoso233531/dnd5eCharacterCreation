import 'package:dio/dio.dart';
import '../models/character_class.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CharacterRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.get('API_BASE_URL'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<CharacterClass>> getClasses() async {
    try {
      final response = await _dio.get('/classes/');
      final List results = response.data['results'];
      return results.map((json) => CharacterClass.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get classes from Open5e: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getRaces() async {
    try {
      final response = await _dio.get(
        'races/?document__slug=wotc-srd&limit=500',
      );
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      throw Exception('Failed to load races: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getBackgrounds() async {
    try {
      final response = await _dio.get('/backgrounds/');
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      throw Exception('Failed to get backgrounds from Open5e: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getFeats() async {
    try {
      final response = await _dio.get('/feats/');
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      throw Exception('Failed to get feats from Open5e: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getSpells(
    String dndClass, {
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/spells/?dnd_class__icontains=$dndClass&document__slug=wotc-srd',
        queryParameters: {'page': page},
      );
      return List<Map<String, dynamic>>.from(response.data['results']);
    } catch (e) {
      throw Exception('Error loading spells page $page for $dndClass: $e');
    }
  }

  Future<int> getSpellsPageCount(String dndClass) async {
    try {
      final response = await _dio.get(
        '/spells/?dnd_class__icontains=$dndClass&document__slug=wotc-srd',
      );

      final count = response.data['count'] as int;
      final results = response.data['results'] as List;

      if (results.isEmpty || count == 0) return 0;

      final pageSize = results.length;
      return (count / pageSize).ceil();
    } catch (_) {
      // La primera página ya fue cargada. Evita inventar páginas adicionales.
      return 1;
    }
  }

  /// Busca hechizos otorgados por una subclase sin restringirlos a la lista
  /// de la clase ni al documento SRD. Esto permite resolver, por ejemplo,
  /// conjuros de dominios, juramentos y círculos de fuentes externas.
  Future<List<Map<String, dynamic>>> getSpellsByNames(
    Iterable<String> spellNames, {
    String? preferredDocumentSlug,
  }) async {
    final uniqueNames = <String, String>{};
    for (final name in spellNames) {
      final trimmed = name.trim();
      if (trimmed.isNotEmpty) {
        uniqueNames.putIfAbsent(trimmed.toLowerCase(), () => trimmed);
      }
    }

    if (uniqueNames.isEmpty) return const [];

    final responses = await Future.wait(
      uniqueNames.values.map((name) async {
        try {
          final response = await _dio.get(
            '/spells/',
            queryParameters: {
              'name__iexact': name,
              'limit': 100,
            },
          );
          final results = List<Map<String, dynamic>>.from(
            response.data['results'] ?? const [],
          );
          return _choosePreferredSpell(
            results,
            preferredDocumentSlug: preferredDocumentSlug,
          );
        } catch (_) {
          return null;
        }
      }),
    );

    return responses.whereType<Map<String, dynamic>>().toList();
  }

  Map<String, dynamic>? _choosePreferredSpell(
    List<Map<String, dynamic>> results, {
    String? preferredDocumentSlug,
  }) {
    if (results.isEmpty) return null;

    if (preferredDocumentSlug != null && preferredDocumentSlug.isNotEmpty) {
      for (final spell in results) {
        if (_documentSlug(spell) == preferredDocumentSlug) return spell;
      }
    }

    for (final spell in results) {
      if (_documentSlug(spell) == 'wotc-srd') return spell;
    }

    return results.first;
  }

  String _documentSlug(Map<String, dynamic> item) {
    final flatSlug = item['document__slug']?.toString();
    if (flatSlug != null && flatSlug.isNotEmpty) return flatSlug;

    final document = item['document'];
    if (document is Map) {
      return document['slug']?.toString() ??
          document['key']?.toString() ??
          '';
    }

    return '';
  }

  Future<List<Map<String, dynamic>>> getArmors() async {
    try {
      final response = await _dio.get('/armor/');
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      throw Exception('Failed to get armor from Open5e: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getWeapons() async {
    try {
      final response = await _dio.get('/weapons/');
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      throw Exception('Failed to get weapons from Open5e: ${e.message}');
    }
  }
}
