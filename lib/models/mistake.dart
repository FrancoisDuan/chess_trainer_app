/// Represents a mistake in a chess game
class Mistake {
  final int moveNumber;
  final String playerMove;
  final String bestMove;
  final double evaluationBefore;
  final double evaluationAfter;
  final double evaluationDifference;
  final String? positionFenBefore;
  final String? positionFenAfter;

  Mistake({
    required this.moveNumber,
    required this.playerMove,
    required this.bestMove,
    required this.evaluationBefore,
    required this.evaluationAfter,
    required this.evaluationDifference,
    this.positionFenBefore,
    this.positionFenAfter,
  });

  factory Mistake.fromJson(Map<String, dynamic> json) {
    return Mistake(
      moveNumber: json['move_number'] as int? ?? 0,
      playerMove: json['player_move'] as String? ?? '',
      bestMove: json['best_move'] as String? ?? '',
      evaluationBefore: ((json['evaluation_before'] ?? 0) as num).toDouble(),
      evaluationAfter: ((json['evaluation_after'] ?? 0) as num).toDouble(),
      evaluationDifference: ((json['evaluation_diff'] ?? json['evaluation_difference'] ?? 0) as num).toDouble(),
      positionFenBefore: json['position_fen_before'] as String?,
      positionFenAfter: json['position_fen_after'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'move_number': moveNumber,
      'player_move': playerMove,
      'best_move': bestMove,
      'evaluation_before': evaluationBefore,
      'evaluation_after': evaluationAfter,
      'evaluation_diff': evaluationDifference,
      'position_fen_before': positionFenBefore,
      'position_fen_after': positionFenAfter,
    };
  }

  /// Get a formatted display of the evaluation
  String formatEvaluation(double eval) {
    if (eval > 100) return '+M'; // Mate for white
    if (eval < -100) return '-M'; // Mate for black
    return eval >= 0 ? '+${eval.toStringAsFixed(1)}' : eval.toStringAsFixed(1);
  }
}