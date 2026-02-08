/// Represents a chess game with metadata
class Game {
  final String id;
  final String whitePlayer;
  final String blackPlayer;
  final String result;
  final String timeControl;
  final DateTime date;
  final String? pgn;

  Game({
    required this.id,
    required this.whitePlayer,
    required this.blackPlayer,
    required this.result,
    required this.timeControl,
    required this.date,
    this.pgn,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      whitePlayer: json['white_player'] as String,
      blackPlayer: json['black_player'] as String,
      result: json['result'] as String,
      timeControl: json['time_control'] as String,
      date: DateTime.parse(json['date'] as String),
      pgn: json['pgn'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'white_player': whitePlayer,
      'black_player': blackPlayer,
      'result': result,
      'time_control': timeControl,
      'date': date.toIso8601String(),
      'pgn': pgn,
    };
  }

  /// Get a formatted display of the game result
  String get resultDisplay {
    switch (result) {
      case '1-0':
        return 'White wins';
      case '0-1':
        return 'Black wins';
      case '1/2-1/2':
        return 'Draw';
      default:
        return result;
    }
  }
}
