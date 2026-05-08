import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/core/error/exceptions.dart';

class DeepSeekClient {
  final FirebaseDatabase _database;
  final http.Client _http;
  String? _apiKey;

  DeepSeekClient({FirebaseDatabase? database, http.Client? httpClient})
      : _database = database ?? FirebaseDatabase.instance,
        _http = httpClient ?? http.Client();

  Future<String> _getApiKey() async {
    if (_apiKey != null) return _apiKey!;

    final snapshot =
        await _database.ref('config/deepseek_api_key').get();
    if (!snapshot.exists || snapshot.value == null) {
      throw ServerException();
    }
    _apiKey = snapshot.value as String;
    return _apiKey!;
  }

  Future<Map<String, dynamic>> chatCompletion({
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.3,
  }) async {
    final key = await _getApiKey();

    try {
      final response = await _http.post(
        Uri.parse('https://api.deepseek.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'response_format': {'type': 'json_object'},
          'temperature': temperature,
        }),
      );

      if (response.statusCode != 200) {
        throw ServerException();
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = body['choices'] as List;
      if (choices.isEmpty) {
        throw ServerException();
      }

      final content = choices[0]['message']['content'] as String;
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }
}
