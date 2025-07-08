class MchatQuestion {
  final int id;
  final String question;
  final bool isCritical;
  final String? followUpQuestion;

  const MchatQuestion({
    required this.id,
    required this.question,
    required this.isCritical,
    this.followUpQuestion,
  });
}