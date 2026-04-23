import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complaint.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      await prefs.setString('user_data', jsonEncode(data['user']));
      return data;
    }
    throw Exception(
        jsonDecode(response.body)['message'] ?? 'Login failed');
  }

  static Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return AppUser.fromJson(jsonDecode(userData));
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static Future<List<Complaint>> getMyComplaints() async {
    final response = await http.get(
      Uri.parse('$baseUrl/complaints/my'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((j) => Complaint.fromJson(j)).toList();
    }
    throw Exception('Failed to load complaints');
  }

  static Future<List<Complaint>> getAllComplaints(
      {String? status}) async {
    String url = '$baseUrl/complaints';
    if (status != null && status != 'ALL') url += '?status=$status';
    final response =
        await http.get(Uri.parse(url), headers: await _headers());
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((j) => Complaint.fromJson(j)).toList();
    }
    throw Exception('Failed to load complaints');
  }

  static Future<Complaint> submitComplaint({
    required String reportedUserId,
    required String violationType,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/complaints'),
      headers: await _headers(),
      body: jsonEncode({
        'reportedUserId': reportedUserId,
        'violationType': violationType,
        'description': description,
      }),
    );
    if (response.statusCode == 201) {
      return Complaint.fromJson(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['message'] ??
        'Failed to submit complaint');
  }

  static Future<Complaint> updateComplaintStatus({
    required String complaintId,
    required String status,
    String? adminNote,
    bool? issueStrike,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/complaints/$complaintId/status'),
      headers: await _headers(),
      body: jsonEncode({
        'status': status,
        if (adminNote != null) 'adminNote': adminNote,
        if (issueStrike != null) 'issueStrike': issueStrike,
      }),
    );
    if (response.statusCode == 200) {
      return Complaint.fromJson(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['message'] ??
        'Failed to update complaint');
  }

  static Future<List<UserSummary>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((j) => UserSummary.fromJson(j)).toList();
    }
    throw Exception('Failed to load users');
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/stats'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load stats');
  }

  static Future<void> banUser(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users/$userId/ban'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ??
          'Failed to ban user');
    }
  }

  static Future<void> unbanUser(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users/$userId/unban'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ??
          'Failed to unban user');
    }
  }
}