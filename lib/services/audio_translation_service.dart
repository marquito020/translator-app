import 'package:dio/dio.dart';
import '../config/dio_config.dart';

class AudioTranslationService {
  Future<Map<String, dynamic>> processAudio({
    required String audioFilePath,
    required String inputLanguage,
    required String outputLanguage,
    required bool playTranslatedAudio,
  }) async {
    try {
      // FormData: Igual que la estructura usada en Postman
      final formData = FormData.fromMap({
        'idioma_entrada': inputLanguage, // Igual que en el servidor
        'idioma_salida': outputLanguage, // Igual que en el servidor
        'reproducir_audio':
            playTranslatedAudio ? 's' : 'n', // Igual que en el servidor
        'audioFile': await MultipartFile.fromFile(
          audioFilePath,
          filename: 'Recording.wav', // Nombre correcto del archivo
        ),
      });

      // Enviar datos al servidor
      final response = await DioConfig.dioWithoutAuthorization.post(
        '/api/upload-audio', // Asegúrate de que este endpoint sea correcto
        data: formData,
      );

      print('Respuesta del servidor: ${response.data}');
      // Validar la respuesta
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error en el servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error al procesar el audio: ${_formatDioError(e)}');
      throw Exception('Error al procesar el audio: ${_formatDioError(e)}');
    }
  }

  // Manejo de errores detallado
  String _formatDioError(DioException e) {
    if (e.response != null) {
      return 'Error: ${e.response?.statusCode}, ${e.response?.data}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Tiempo de conexión agotado';
    } else {
      return 'Error inesperado: ${e.message}';
    }
  }
}
