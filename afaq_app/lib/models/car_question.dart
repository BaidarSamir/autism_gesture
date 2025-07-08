import 'package:autism_screener/models/option.dart';

class CarQuestion {
  final String question;
  final List<Option> options;

  const CarQuestion({required this.question, required this.options});

  factory CarQuestion.fromJson(Map<String, dynamic> json) {
    final question = json['question'] as String;
    final optionsList = json['options'] as List<dynamic>;

    final options = optionsList
        .map((e) => Option.fromJson(e as Map<String, dynamic>))
        .toList();

    return CarQuestion(question: question, options: options);
  }
}
