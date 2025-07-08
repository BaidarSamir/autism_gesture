import 'package:autism_screener/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TestResultScreen extends StatelessWidget {
  const TestResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments == null) {
      return _buildErrorScreen(context, 'لم يتم العثور على نتائج الاختبار');
    }

    final String testName = arguments['testName'] ?? 'اختبار غير محدد';
    final double score = arguments['score'] ?? 0;
    final double maxScore = arguments['maxScore'] ?? 60;
    final String? providedRiskLevel = arguments['riskLevel'];

    if (score < 0 || score > maxScore) {
      return _buildErrorScreen(
        context,
        'النتيجة غير صحيحة: $score من $maxScore',
      );
    }

    final RiskAssessment riskAssessment = _getRiskAssessment(
      score,
      providedRiskLevel,
      testName,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'نتيجة الاختبار',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      _buildResultCard(
                        testName,
                        score,
                        maxScore,
                        riskAssessment,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButtons(context, score, riskAssessment),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'خطأ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.error,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.warning_2,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
                icon: const Icon(Iconsax.home_2),
                label: const Text('العودة للصفحة الرئيسية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String testName,
    double score,
    double maxScore,
    RiskAssessment riskAssessment,
  ) {
    final double percentage = (score / maxScore * 100);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.clipboard_tick,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              testName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surfaceVariant,
                    AppColors.accent.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.award, color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'النتيجة النهائية',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$score من $maxScore',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: riskAssessment.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: riskAssessment.color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getRiskIcon(riskAssessment.level),
                        color: riskAssessment.color,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مستوى التشخيص',
                        style: TextStyle(
                          fontSize: 16,
                          color: riskAssessment.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: riskAssessment.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      riskAssessment.level,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: riskAssessment.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    double score,
    RiskAssessment riskAssessment,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          icon: const Icon(Iconsax.home_2),
          label: const Text(
            'العودة للصفحة الرئيسية',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            _showDetailedResults(context, score, riskAssessment);
          },
          icon: Icon(Iconsax.document_text, color: AppColors.accent),
          label: Text(
            'عرض النتائج بالتفصيل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(color: AppColors.accent, width: 2),
          ),
        ),
      ],
    );
  }

  IconData _getRiskIcon(String riskLevel) {
    if (riskLevel.contains('لا يوجد') || riskLevel.contains('ضعيف')) {
      return Iconsax.tick_circle;
    } else if (riskLevel.contains('بسيط') || riskLevel.contains('متوسط')) {
      return Iconsax.warning_2;
    } else if (riskLevel.contains('شديد')) {
      return Iconsax.danger;
    } else {
      return Iconsax.info_circle;
    }
  }

  RiskAssessment _getRiskAssessment(
    double score,
    String? providedRiskLevel,
    String testName,
  ) {
    // Use provided risk level if available, otherwise calculate
    if (providedRiskLevel != null && providedRiskLevel.isNotEmpty) {
      switch (providedRiskLevel) {
        case 'لا يوجد توحد':
          return RiskAssessment(
            level: 'لا يوجد توحد',
            color: AppColors.success,
            description:
                'لا توجد علامات واضحة لاضطراب طيف التوحد. يمكنك متابعة النمو الطبيعي لطفلك مع المراقبة المستمرة.',
          );
        case 'توحد بسيط':
        case 'توحد بسيط إلى متوسط':
          return RiskAssessment(
            level: 'توحد بسيط إلى متوسط',
            color: AppColors.warning,
            description:
                'يظهر طفلك علامات بسيطة إلى متوسطة لاضطراب طيف التوحد. نوصي بمراجعة أخصائي للتقييم والتدخل المبكر.',
          );
        case 'توحد شديد':
          return RiskAssessment(
            level: 'توحد شديد',
            color: AppColors.error,
            description:
                'يظهر طفلك علامات شديدة لاضطراب طيف التوحد. من المهم جداً مراجعة أخصائي فوراً لوضع خطة علاجية شاملة.',
          );
      }
    }

    String getRiskLevel(double totalScore) {
      if (totalScore <= 2) {
        return 'احتمال ضعيف ';
      } else if (totalScore >= 3 && totalScore <= 7) {
        return 'متوسط الخطورة';
      } else {
        return 'شديد الخطورة';
      }
    }

    if (testName == "M-CHAT") {
      String level = getRiskLevel(score);

      if (level == 'احتمال ضعيف ') {
        return RiskAssessment(
          level: level,
          color: AppColors.success,
          description:
              'لا توجد مؤشرات قوية للتوحد. يفضل المراقبة الدورية لنمو الطفل.',
        );
      } else if (level == 'متوسط الخطورة') {
        return RiskAssessment(
          level: level,
          color: AppColors.warning,
          description:
              'قد توجد بعض العلامات المرتبطة بالتوحد. يُنصح بمراجعة مختص لمزيد من التقييم.',
        );
      } else {
        return RiskAssessment(
          level: level,
          color: AppColors.error,
          description:
              'هناك مؤشرات قوية لاحتمال الإصابة بالتوحد. من الضروري زيارة أخصائي في أقرب وقت.',
        );
      }
    } else {
      if (score >= 15 && score <= 30) {
        return RiskAssessment(
          level: 'لا يوجد توحد',
          color: AppColors.success,
          description:
              'لا توجد علامات واضحة لاضطراب طيف التوحد. يمكنك متابعة النمو الطبيعي لطفلك مع المراقبة المستمرة.',
        );
      } else if (score >= 31 && score <= 37) {
        return RiskAssessment(
          level: 'توحد بسيط إلى متوسط',
          color: AppColors.warning,
          description:
              'يظهر طفلك علامات بسيطة إلى متوسطة لاضطراب طيف التوحد. نوصي بمراجعة أخصائي للتقييم والتدخل المبكر.',
        );
      } else if (score >= 38 && score <= 60) {
        return RiskAssessment(
          level: 'توحد شديد',
          color: AppColors.error,
          description:
              'يظهر طفلك علامات شديدة لاضطراب طيف التوحد. من المهم جداً مراجعة أخصائي فوراً لوضع خطة علاجية شاملة.',
        );
      } else {
        return RiskAssessment(
          level: 'نتيجة غير متوقعة',
          color: AppColors.textDisabled,
          description:
              'النتيجة خارج النطاق المتوقع. يرجى إعادة الاختبار أو مراجعة أخصائي للتقييم.',
        );
      }
    }
  }

  void _showDetailedResults(
    BuildContext context,
    double score,
    RiskAssessment riskAssessment,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.document_text,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'النتائج التفصيلية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'النتيجة النهائية',
                        '$score',
                        Iconsax.award,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'التشخيص',
                        riskAssessment.level,
                        _getRiskIcon(riskAssessment.level),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Iconsax.close_circle, color: AppColors.textSecondary),
              label: Text(
                'إغلاق',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class RiskAssessment {
  final String level;
  final Color color;
  final String description;

  RiskAssessment({
    required this.level,
    required this.color,
    required this.description,
  });
}
