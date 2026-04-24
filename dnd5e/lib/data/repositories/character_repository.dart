import 'package:dio/dio.dart';
import '../models/character_class.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CharacterRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.get('API_BASE_URL'),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

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
}