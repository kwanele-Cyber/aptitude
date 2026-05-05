import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseClient {
  final String apiKey;
  final String databaseUrl;

  FirebaseClient({required this.apiKey, required this.databaseUrl});

  Future<AuthResult> signUp(String email, String password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final msg = body['error']['message'] as String? ?? 'Unknown error';
      if (msg == 'EMAIL_EXISTS') {
        throw FirebaseEmailExistsException(email);
      }
      throw FirebaseApiException(msg);
    }
    return AuthResult(
      uid: body['localId'] as String,
      idToken: body['idToken'] as String,
    );
  }

  Future<AuthResult> signIn(String email, String password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw FirebaseApiException(
        body['error']['message'] as String? ?? 'Sign in failed',
      );
    }
    return AuthResult(
      uid: body['localId'] as String,
      idToken: body['idToken'] as String,
    );
  }

  Future<void> put(String path, Map<String, dynamic> data,
      {String? idToken}) async {
    var url = '$databaseUrl/$path.json';
    if (idToken != null) url += '?auth=$idToken';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw FirebaseApiException(body['error'] as String? ?? 'Write failed');
    }
  }

  Future<String> post(String path, Map<String, dynamic> data,
      {String? idToken}) async {
    var url = '$databaseUrl/$path.json';
    if (idToken != null) url += '?auth=$idToken';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw FirebaseApiException(body['error'] as String? ?? 'Write failed');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['name'] as String;
  }
}

class AuthResult {
  final String uid;
  final String idToken;
  const AuthResult({required this.uid, required this.idToken});
}

class FirebaseApiException implements Exception {
  final String message;
  const FirebaseApiException(this.message);
  @override
  String toString() => 'Firebase API error: $message';
}

class FirebaseEmailExistsException implements Exception {
  final String email;
  const FirebaseEmailExistsException(this.email);
  @override
  String toString() => 'Email already exists: $email';
}
