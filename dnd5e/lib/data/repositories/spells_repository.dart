import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpellsRepository {
  SpellsRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: dotenv.get('API_BASE_URL'),
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getSpells() async {
    try {
      final response = await _dio.get(
        '/spells/',
        queryParameters: {
          'document__slug': 'wotc-srd',
          'limit': 500,
        },
      );

      final data = response.data;

      if (data is! Map || data['results'] is! List) {
        throw const FormatException(
          'The spells response does not contain a results list.',
        );
      }

      return List<Map<String, dynamic>>.from(
        data['results'] as List,
      );
    } on DioException catch (error) {
      throw Exception(
        'Failed to get spells from Open5e: '
        '${error.message}',
      );
    } on FormatException catch (error) {
      throw Exception(error.message);
    }
  }
}