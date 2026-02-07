/// Represents a Chess.com user
class User {
  final String username;
  final int gamesAnalyzed;

  User({
    required this.username,
    required this.gamesAnalyzed,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      gamesAnalyzed: json['games_analyzed'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'games_analyzed': gamesAnalyzed,
    };
  }
}
