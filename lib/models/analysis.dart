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
    return Analysis(
      gameId: json['game_id'] as String,
      game: Game.fromJson(json['game'] as Map<String, dynamic>),
      mistakes: (json['mistakes'] as List<dynamic>)
          .map((m) => Mistake.fromJson(m as Map<String, dynamic>))
          .toList(),
      totalMistakes: json['total_mistakes'] as int? ?? 0,
      analyzedAt: DateTime.parse(json['analyzed_at'] as String),
    );
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
