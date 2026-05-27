import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tweet.dart';
import '../models/tweet_response.dart';
import '../repositories/tweet_repository.dart';
import 'auth_service.dart';

/// Singleton service implementing the Repository Pattern
/// Implements: Singleton Pattern + Repository Pattern + Error Handling
/// Follows SOLID principles: Single Responsibility, Dependency Inversion
class TweetService implements ITweetRepository {
  static final TweetService _instance = TweetService._internal();

  //final String baseUrl = 'https://adsoftsito-api.render.com/api';
  final String baseUrl = 'http://localhost:8080/api';
  late http.Client _httpClient;
  late AuthService _authService;

  // Private constructor
  TweetService._internal() {
    _httpClient = http.Client();
    _authService = AuthService();
  }

  /// Factory constructor that always returns the same instance
  factory TweetService() {
    return _instance;
  }

  /// Get the singleton instance
  static TweetService getInstance() {
    return _instance;
  }

  /// Get headers with authentication token
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

  @override
  Future<List<Tweet>> fetchTweets() async {
    try {
      // Ensure auth is initialized before getting token
      await _authService.init();

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/tweets'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return _parseGetTweetsResponse(response.body);
      } else {
        throw Exception(
          'Failed to load tweets. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching tweets: $e');
    }
  }

  @override
  Future<Tweet> createTweet(String content) async {
    try {
      if (content.isEmpty) {
        throw Exception('Tweet content cannot be empty');
      }

      // Ensure auth is initialized before getting token
      await _authService.init();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/tweets'),
        headers: _getHeaders(),
        body: jsonEncode({'tweet': content}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseTweetResponse(response.body);
      } else {
        throw Exception(
          'Failed to create tweet. Status code: ${response.statusCode}. ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating tweet: $e');
    }
  }

  @override
  Future<void> deleteTweet(int id) async {
    try {
      // Ensure auth is initialized before getting token
      await _authService.init();

      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/tweets/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Failed to delete tweet. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting tweet: $e');
    }
  }

  /// Parse GET tweets response - Single Responsibility
  List<Tweet> _parseGetTweetsResponse(String responseBody) {
    final jsonData = jsonDecode(responseBody);
    final jsonMap = Map<String, dynamic>.from(jsonData as Map);
    final tweetResponse = TweetResponse.fromJson(jsonMap);
    return tweetResponse.content;
  }

  /// Parse single tweet response - Single Responsibility
  Tweet _parseTweetResponse(String responseBody) {
    final jsonData = jsonDecode(responseBody);
    final jsonMap = Map<String, dynamic>.from(jsonData as Map);
    return Tweet.fromJson(jsonMap);
  }

  /// Close the HTTP client (cleanup)
  @override
  void dispose() {
    _httpClient.close();
  }
}
