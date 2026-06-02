import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BestiaryRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.get('API_BASE_URL', fallback: 'https://api.open5e.com'),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // Ahora devuelve un Map con toda la respuesta, incluyendo "next" y "results"
  Future<Map<String, dynamic>> getMonstersPage(String? url) async {
    try {
      // Si la URL es nula, es la primera petición. limit=200 es rápido y ligero.
      final targetUrl = url ?? 'monsters/?limit=200';
      final response = await _dio.get(targetUrl);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to get monsters: ${e.message}');
    }
  }
}