import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];

    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL no está configurada en el archivo .env');
    }

    return url;
  }
}