import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/game.dart';
import '../models/analysis.dart';

/// Service class for communicating with the Chess Trainer backend API
class ChessTrainerApiService {
  final String baseUrl;
  final http.Client client;

  ChessTrainerApiService({
    this.baseUrl = 'http://10.0.2.2:8000',
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Analyze games for a Chess.com username
  /// POST /analyze
  Future<User> analyzeUser(String username) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(jsonData);
      } else {
        throw ApiException(
          'Failed to analyze user: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

/// Get list of analyzed games for a user
/// GET /api/user/{username}/games
Future<List<Game>> getUserGames(String username) async {
  try {
    final response = await client.get(
      Uri.parse('$baseUrl/api/user/$username/games'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      
      // Handle both formats: array or object with games field
      List<dynamic> gamesList;
      if (jsonData is List) {
        gamesList = jsonData;
      } else if (jsonData is Map && jsonData['games'] != null) {
        gamesList = jsonData['games'] as List<dynamic>;
      } else {
        throw ApiException('Unexpected response format', response.statusCode);
      }
      
      return gamesList
          .map((game) => Game.fromJson(game as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        'Failed to fetch games: ${response.statusCode}',
        response.statusCode,
      );
    }
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: $e', 0);
  }
}

  /// Get detailed analysis for a specific game
  /// GET /api/analysis/{game_id}
  Future<Analysis> getGameAnalysis(String gameId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/analysis/$gameId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return Analysis.fromJson(jsonData);
      } else {
        throw ApiException(
          'Failed to fetch analysis: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    client.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
