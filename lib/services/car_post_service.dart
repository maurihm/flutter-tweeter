import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/car_post.dart';
import 'auth_service.dart';

class CarPostService {
  late http.Client _httpClient;
  late AuthService _authService;

  CarPostService._internal() {
    _httpClient = http.Client();
    _authService = AuthService();
  }

  factory CarPostService() => CarPostService._internal();

  String get baseUrl => ApiConfig.baseUrl;

  Map<String, String> _getHeaders() {
    final token = _authService.getToken();
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  List<CarPost> _parsePosts(String responseBody) {
    final decoded = jsonDecode(responseBody);

    if (decoded is List) {
      return decoded
          .map((item) => CarPost.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    if (decoded is Map<String, dynamic>) {
      final content = decoded['content'];
      if (content is List) {
        return content
            .map((item) => CarPost.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    }

    return const [];
  }

  CarPost _parsePost(String responseBody) {
    final jsonData = jsonDecode(responseBody);
    final jsonMap = Map<String, dynamic>.from(jsonData as Map);
    return CarPost.fromJson(jsonMap);
  }

  Future<List<CarPost>> fetchPosts() async {
    await _authService.init();

    final response = await _httpClient.get(
      Uri.parse('$baseUrl/posts'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return _parsePosts(response.body);
    }

    throw Exception('Error fetching posts: ${response.statusCode} ${response.body}');
  }

  Future<CarPost> createPost({
    required String title,
    required String photoUrl,
    String? brand,
    String? model,
    int? year,
    String? description,
  }) async {
    await _authService.init();

    final response = await _httpClient.post(
      Uri.parse('$baseUrl/posts'),
      headers: _getHeaders(),
      body: jsonEncode({
        'title': title,
        'brand': brand,
        'model': model,
        'year': year,
        'photoUrl': photoUrl,
        'description': description,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _parsePost(response.body);
    }

    throw Exception('Error creating post: ${response.statusCode} ${response.body}');
  }

  Future<void> deletePost(int id) async {
    await _authService.init();

    final response = await _httpClient.delete(
      Uri.parse('$baseUrl/posts/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error deleting post: ${response.statusCode} ${response.body}');
    }
  }

  void dispose() {}
}