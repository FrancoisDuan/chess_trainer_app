/// Represents a mistake in a chess game
class Mistake {
  final int moveNumber;
  final String playerMove;
  final String bestMove;
  final double evaluationBefore;
  final double evaluationAfter;
  final double evaluationDifference;
  final String? fen;

  Mistake({
    required this.moveNumber,
    required this.playerMove,
    required this.bestMove,
    required this.evaluationBefore,
    required this.evaluationAfter,
    required this.evaluationDifference,
    this.fen,
  });

  factory Mistake.fromJson(Map<String, dynamic> json) {
    return Mistake(
      moveNumber: json['move_number'] as int,
      playerMove: json['player_move'] as String,
      bestMove: json['best_move'] as String,
      evaluationBefore: (json['evaluation_before'] as num).toDouble(),
      evaluationAfter: (json['evaluation_after'] as num).toDouble(),
      evaluationDifference: (json['evaluation_difference'] as num).toDouble(),
      fen: json['fen'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'move_number': moveNumber,
      'player_move': playerMove,
      'best_move': bestMove,
      'evaluation_before': evaluationBefore,
      'evaluation_after': evaluationAfter,
      'evaluation_difference': evaluationDifference,
      'fen': fen,
    };
  }

  /// Get a formatted display of the evaluation
  String formatEvaluation(double eval) {
    if (eval > 100) return '+M'; // Mate for white
    if (eval < -100) return '-M'; // Mate for black
    return eval >= 0 ? '+${eval.toStringAsFixed(1)}' : eval.toStringAsFixed(1);
  }
}
