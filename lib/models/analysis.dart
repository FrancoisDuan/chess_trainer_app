import 'game.dart';
import 'mistake.dart';

/// Represents the analysis of a chess game
class Analysis {
  final String gameId;
  final Game game;
  final List<Mistake> mistakes;
  final int totalMistakes;
  final DateTime analyzedAt;

  Analysis({
    required this.gameId,
    required this.game,
    required this.mistakes,
    required this.totalMistakes,
    required this.analyzedAt,
  });

factory Analysis.fromJson(Map<String, dynamic> json) {
  try {
    // Try both 'game' and 'game_metadata' field names
    final gameData = json['game'] ?? json['game_metadata'];
    
    if (gameData == null) {
      throw Exception('No game data found in analysis response');
    }
    
    // Handle both response formats:
    // Format 1: mistakes at top level (json['mistakes'])
    // Format 2: mistakes nested in analysis object (json['analysis']['mistakes'])
    final analysisData = json['analysis'] as Map<String, dynamic>?;
    final mistakesList = (json['mistakes'] as List<dynamic>?) ?? 
                         (analysisData?['mistakes'] as List<dynamic>?) ?? [];
    final totalMistakes = (json['total_mistakes'] as int?) ?? 
                          (analysisData?['mistakes_count'] as int?) ?? 0;
    final analyzedAt = (json['analyzed_at'] as String?) ?? 
                       (analysisData?['analysis_date'] as String?);
    
    return Analysis(
      gameId: json['game_id'] as String? ?? '',
      game: Game.fromJson(gameData as Map<String, dynamic>),
      mistakes: mistakesList
          .map((m) => Mistake.fromJson(m as Map<String, dynamic>))
          .toList(),
      totalMistakes: totalMistakes,
      analyzedAt: DateTime.tryParse(analyzedAt ?? '') ?? DateTime.now(),
    );
  } catch (e) {
    rethrow;
  }
}

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'game': game.toJson(),
      'mistakes': mistakes.map((m) => m.toJson()).toList(),
      'total_mistakes': totalMistakes,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }
}
