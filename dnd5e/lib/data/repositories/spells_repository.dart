import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpellsRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.get('API_BASE_URL'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Map<String, dynamic>>> getSpells() async {
    try {
      final response = await _dio.get('/spells/?document__slug=wotc-srd&limit=500');
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      throw Exception('Failed to get spells from Open5e: ${e.message}');
    }
  }
}