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
  print('DEBUG: Parsing game JSON: $json');
  
  try {
    final dateStr = json['date'] as String?;
    DateTime parsedDate = DateTime.now();
    
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        final timestamp = int.parse(dateStr);
        parsedDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      } catch (e) {
        print('DEBUG: Failed to parse timestamp: $dateStr');
      }
    }

    return Game(
      id: (json['game_id'] ?? '') as String,
      whitePlayer: (json['white_player'] ?? 'Unknown') as String,
      blackPlayer: (json['black_player'] ?? 'Unknown') as String,
      result: (json['result'] ?? 'unknown') as String,
      timeControl: (json['time_control'] ?? '0').toString(), // Convert to string
      date: parsedDate,
      pgn: json['pgn'] as String?,
    );
  } catch (e) {
    print('DEBUG: Error parsing game: $e');
    print('DEBUG: JSON was: $json');
    rethrow;
  }
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
