class Tweet {
  final int? id;
  final String tweet;
  final String createdAt;
  final String? updatedAt;

  Tweet({
    this.id,
    required this.tweet,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor para crear un Tweet desde JSON
  /// Procesa la respuesta del backend
  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
      id: json['id'] as int?,
      tweet: json['tweet'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Convierte el Tweet a JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'tweet': tweet,
    };
  }

  @override
  String toString() => 'Tweet(id: $id, tweet: $tweet, createdAt: $createdAt)';
}
