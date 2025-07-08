import 'package:autism_screener/data/cars_mchat_questions.dart';
import 'package:autism_screener/models/car_question.dart';
import 'package:autism_screener/models/option.dart';
import 'package:autism_screener/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CarsMchatQuestionScreen extends StatefulWidget {
  const CarsMchatQuestionScreen({super.key});

  @override
  State<CarsMchatQuestionScreen> createState() =>
      _CarsMchatQuestionScreenState();
}

class _CarsMchatQuestionScreenState extends State<CarsMchatQuestionScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  bool _showInstructions = true;
  final Map<int, double> _answers = {};
  late AnimationController _slideController;

  String get testName => 'CARS-2';
  int get totalQuestions => carsQuestions.length;

  String get testDescription =>
      'مقياس تقدير التوحد في الطفولة الإصدار الثاني. يقيس هذا المقياس شدة أعراض التوحد عبر 15 بعداً مختلفاً للسلوك والتطور.';

  List<String> get testSteps => [
    'اقرأ كل عبارة بعناية وحدد مدى انطباقها على الطفل',
    'استخدم الملاحظة المباشرة والمعلومات من الوالدين',
    'قيم السلوك خلال الأسابيع الأخيرة',
    'في حالة عدم التأكد، اختر الدرجة الأقل',
    'انتبه للأسئلة الحرجة التي لها وزن أكبر في التقييم',
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _showInstructions = false;
    });
  }

  void _answerQuestion(double score) {
    setState(() {
      _answers[_currentQuestionIndex] = score;
      if (_currentQuestionIndex < totalQuestions - 1) {
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

  Future<void> _calculateScore() async {
    try {
      setState(() => _isLoading = true);

      double totalScore = 0.0;
      for (int i = 0; i < totalQuestions; i++) {
        totalScore += _answers[i] ?? 1.0;
      }

      String riskLevel = _getRiskLevel(totalScore);
      double maxScore = totalQuestions * 3.5;

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/test_result',
        arguments: {
          'testName': testName,
          'score': totalScore,
          'maxScore': maxScore,
          'riskLevel': riskLevel,
        },
      );
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _getRiskLevel(double totalScore) {
    if (totalScore >= 15.0 && totalScore < 30.0) {
      return 'لا يوجد توحد';
    } else if (totalScore >= 30.0 && totalScore < 37.0) {
      return 'توحد بسيط إلى متوسط';
    } else if (totalScore >= 37.0) {
      return 'توحد شديد';
    } else {
      return 'غير محدد';
    }
  }

  Widget _buildInstructionScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'CARS-2 + M-CHAT',
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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTestInfoCard(),
                  const SizedBox(height: 24),
                  _buildStepsCard(),
                  const SizedBox(height: 24),
                  _buildStartButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surfaceVariant, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Iconsax.info_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  testName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            testDescription,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surfaceVariant, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Iconsax.document,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'خطوات التطبيق',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...testSteps.asMap().entries.map((entry) {
            return AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    (1 - _slideController.value) * (entry.key + 1) * 20,
                  ),
                  child: Opacity(
                    opacity: _slideController.value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _startTest,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.play, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'بدء الاختبار',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final currentQuestion = carsQuestions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;
    final currentAnswer = _answers[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Iconsax.note_1,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            testName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressIndicator(),
                  const SizedBox(height: 20),
                  _buildQuestionCard(currentQuestion),
                  const SizedBox(height: 20),
                  ...currentQuestion.options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionButton(option, currentAnswer),
                    );
                  }),
                  const SizedBox(height: 20),
                  _buildNavigationButtons(isLastQuestion, currentAnswer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / totalQuestions,
          backgroundColor: AppColors.divider,
          color: AppColors.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
          'السؤال ${_currentQuestionIndex + 1} من $totalQuestions',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(CarQuestion question) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        question.question,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildOptionButton(Option option, double? currentAnswer) {
    bool isSelected = currentAnswer == option.score;
    Color buttonColor = _getScoreColor(option.score);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: isSelected ? buttonColor : buttonColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _answerQuestion(option.score),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: [
                if (isSelected)
                  const Icon(
                    Iconsax.tick_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                if (isSelected) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isLastQuestion, double? currentAnswer) {
    return Row(
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
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text(
                'السابق',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (_currentQuestionIndex > 0) const SizedBox(width: 12),
        if (!isLastQuestion)
          Expanded(
            child: ElevatedButton(
              onPressed: currentAnswer != null
                  ? () => setState(() {
                      if (_currentQuestionIndex < totalQuestions - 1) {
                        _currentQuestionIndex++;
                      }
                    })
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'التالي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'إنهاء الاختبار',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score == 1.0)
      return AppColors.success;
    else if (score == 1.5)
      return AppColors.warning;
    else if (score == 2.5)
      return const Color(0xFFE67E22);
    else
      return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return _showInstructions
        ? _buildInstructionScreen()
        : _buildQuestionScreen();
  }
}
