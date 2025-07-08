class Option {
  final String text;
  final double score;

  const Option({required this.text, required this.score});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      text: json['text'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }
}
