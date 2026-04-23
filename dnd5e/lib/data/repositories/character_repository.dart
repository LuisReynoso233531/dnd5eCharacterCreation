import 'package:dio/dio.dart';
import '../models/character_class.dart';

class CharacterRepository {
  // Configuramos Dio para la API de Open5e
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.open5e.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // Obtener la lista de clases (Guerrero, Mago, etc.)
  Future<List<CharacterClass>> getClasses() async {
    try {
      final response = await _dio.get('/classes/');
      
      // La API devuelve los datos dentro de un campo llamado 'results'
      final List results = response.data['results'];
      
      return results.map((json) => CharacterClass.fromJson(json)).toList();
    } on DioException catch (e) {
      // Aquí podrías manejar errores de red específicos
      throw Exception('Error al obtener clases de Open5e: ${e.message}');
    }
  }
}