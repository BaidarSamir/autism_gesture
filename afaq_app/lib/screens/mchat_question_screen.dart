import 'package:autism_screener/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:autism_screener/data/mchat_questions.dart';

class MchatQuestionScreen extends StatefulWidget {
  final String testName;
  final int totalQuestions;
  final String testDescription;

  MchatQuestionScreen({super.key})
    : testName = 'M-CHAT',
      totalQuestions = MchatQuestions.questions.length,
      testDescription =
          'قائمة فحص التوحد المعدلة للأطفال الصغار (M-CHAT) هي أداة فحص مصممة للكشف المبكر عن علامات التوحد لدى الأطفال الذين تتراوح أعمارهم بين 16 و 30 شهراً.';
  @override
  State<MchatQuestionScreen> createState() => _MchatQuestionScreenState();
}

class _MchatQuestionScreenState extends State<MchatQuestionScreen> {
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  bool _showInstructions = true;
  final Map<int, int> _answers = {};
  final testSteps = [
    'اقرأ كل سؤال بعناية وأجب بـ "نعم" أو "لا" حسب سلوك الطفل المعتاد',
    'فكر في سلوك طفلك خلال الأسابيع القليلة الماضية',
    'إذا كان السلوك نادر الحدوث (أقل من مرتين)، فأجب بـ "لا"',
    'إذا لم تكن متأكداً من الإجابة، اختر "لا"',
    'تذكر أن هذا الفحص للأطفال من عمر 16-30 شهر',
  ];
  String getQuestionText(int index) => testSteps[index];
  String getTestId() => 'mchat';

  List<Map<String, dynamic>> get answerOptions => [
    {'text': 'نعم', 'score': 1, 'color': AppColors.success},
    {'text': 'لا', 'score': 0, 'color': AppColors.error},
  ];

  void _startTest() {
    setState(() {
      _showInstructions = false;
    });
  }

  void _answerQuestion(int score) {
    setState(() {
      final isYesAnswer = score == 1;
      final isScoredYesQuestion = [1, 4, 11].contains(_currentQuestionIndex);

      if (isYesAnswer && isScoredYesQuestion) {
        _answers[_currentQuestionIndex] = 1;
      } else if (!isYesAnswer && !isScoredYesQuestion) {
        _answers[_currentQuestionIndex] = 1;
      } else {
        _answers[_currentQuestionIndex] = 0;
      }

      if (_currentQuestionIndex < widget.totalQuestions - 1) {
        _currentQuestionIndex++;
      } else {
        _calculateScore();
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  String _getRiskLevel(int totalScore) {
    if (totalScore <= 2) {
      return 'احتمال ضعيف';
    } else if (totalScore >= 3 && totalScore <= 7) {
      return 'متوسط الخطورة';
    } else {
      return 'شديد الخطورة';
    }
  }

  Future<void> _calculateScore() async {
    try {
      setState(() => _isLoading = true);

      int totalScore = 0;
      for (int i = 0; i < widget.totalQuestions; i++) {
        totalScore += _answers[i] ?? 0;
      }

      String riskLevel = _getRiskLevel(totalScore);
      int maxScore = widget.totalQuestions;

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/test_result',
        arguments: {
          'testName': widget.testName,
          'score': totalScore.toDouble(),
          'maxScore': maxScore.toDouble(),
          'riskLevel': riskLevel,
        },
      );
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildInstructionScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'تعليمات M-CHAT',
          style: TextStyle(
            color: AppColors.surface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3, color: AppColors.surface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Iconsax.user_cirlce_add,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.testName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تعريف المقياس:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.testDescription,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'خطوات التطبيق:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...testSteps.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.play, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'بدء تطبيق المقياس',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final currentQuestionText = getQuestionText(_currentQuestionIndex);
    final isLastQuestion = _currentQuestionIndex == widget.totalQuestions - 1;
    final currentAnswer = _answers[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'فحص ${widget.testName}',
          style: const TextStyle(
            color: AppColors.surface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3, color: AppColors.surface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / widget.totalQuestions,
                backgroundColor: AppColors.divider,
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              Text(
                'السؤال ${_currentQuestionIndex + 1} من ${widget.totalQuestions}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        currentQuestionText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...answerOptions.map((option) {
                bool isSelected = currentAnswer == option['score'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(option['score']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? option['color']
                          : option['color'].withOpacity(0.8),
                      foregroundColor: AppColors.surface,
                      elevation: isSelected ? 4 : 2,
                      shadowColor: option['color'].withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: isSelected
                            ? BorderSide(color: option['color'], width: 2)
                            : BorderSide.none,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      option['text'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: AppColors.primary),
                        ),
                        child: Text(
                          'السابق',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                  if (!isLastQuestion)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentAnswer != null
                            ? () => _answerQuestion(currentAnswer)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          elevation: 4,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'التالي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (isLastQuestion)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _calculateScore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.surface,
                          elevation: 4,
                          shadowColor: AppColors.success.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'إنهاء الاختبار',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showInstructions
        ? _buildInstructionScreen()
        : _buildQuestionScreen();
  }
}
