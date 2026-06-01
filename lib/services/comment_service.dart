import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class CommentService {
  final http.Client _http = http.Client();
  final AuthService _auth = AuthService();

  String get baseUrl => ApiConfig.baseUrl;

  Map<String, String> _headers() {
    final token = _auth.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<Map<String, dynamic>> createComment(int postId, String content) async {
    await _auth.init();
    final resp = await _http.post(Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: _headers(), body: jsonEncode({'content': content}));
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Error creating comment: ${resp.statusCode} ${resp.body}');
  }

  Future<void> deleteComment(int postId, int commentId) async {
    await _auth.init();
    final resp = await _http.delete(Uri.parse('$baseUrl/posts/$postId/comments/$commentId'), headers: _headers());
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Error deleting comment: ${resp.statusCode} ${resp.body}');
    }
  }
}
