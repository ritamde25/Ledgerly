import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static late final EnvConfig _instance;

  EnvConfig._internal();

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    _instance = EnvConfig._internal();
  }

  static EnvConfig get instance => _instance;

  String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL not found in .env file');
    }
    return url;
  }

  String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in .env file');
    }
    return key;
  }

  String get flaskApiUrl {
    final url = dotenv.env['FLASK_API_URL'];
    if (url == null || url.isEmpty) {
      return 'http://10.0.2.2:5000';
    }
    return url;
  }
}
