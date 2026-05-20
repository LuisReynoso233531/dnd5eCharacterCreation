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

  // Obtener la lista de clases (Fighter, Wizard, etc.)
  Future<List<CharacterClass>> getClasses() async {
    try {
      final response = await _dio.get('/classes/');
      final List results = response.data['results'];
      return results.map((json) => CharacterClass.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get classes from Open5e: ${e.message}');
    }
  }

  // Obtener la lista de razas (Human, Elf, etc.)
  Future<List<Map<String, dynamic>>> getRaces() async {
    try {
      final response = await _dio.get('/races/');
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
      throw Exception('Failed to get classes from Open5e: ${e.message}');
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
    // Es vital aplicar el mismo filtro de clase aquí
    final response = await _dio.get(
      '/spells/?dnd_class__icontains=$dndClass&document__slug=wotc-srd',
    );
    
    final count = response.data['count'] as int;
    final results = response.data['results'] as List;
    
    if (results.isEmpty || count == 0) return 0;
    
    final pageSize = results.length;
    return (count / pageSize).ceil();
  } catch (e) {
    return 29; 
  }
}
}
