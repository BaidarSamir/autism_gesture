import 'package:autism_screener/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ScaleTestsScreen extends StatelessWidget {
  const ScaleTestsScreen({super.key});

  void _navigateToTest(BuildContext context, String testType) {
    switch (testType) {
      case 'mchat':
        Navigator.pushNamed(context, '/mchat_questions');
        break;

      case 'cars_mchat':
        Navigator.pushNamed(context, '/cars_mchat_questions');
        break;
      case 'gars3':
        _showComingSoonDialog(context);
        break;
    }
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Iconsax.timer, color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'قريباً',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: const Text(
            'هذه الميزة قيد التطوير وستكون متاحة قريباً.\nشكراً لصبركم!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'حسناً',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTestCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required String testType,
    bool isDisabled = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDisabled ? AppColors.divider : color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? AppColors.textDisabled.withOpacity(0.1)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: isDisabled ? AppColors.textDisabled : color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDisabled
                              ? AppColors.textDisabled
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDisabled ? AppColors.textDisabled : color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDisabled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.timer, size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        const Text(
                          'قريباً',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: isDisabled
                    ? AppColors.textDisabled
                    : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isDisabled
                    ? () => _showComingSoonDialog(context)
                    : () => _navigateToTest(context, testType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDisabled ? AppColors.divider : color,
                  foregroundColor: isDisabled
                      ? AppColors.textDisabled
                      : AppColors.surface,
                  elevation: isDisabled ? 0 : 4,
                  shadowColor: isDisabled
                      ? Colors.transparent
                      : color.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isDisabled ? Iconsax.timer : Iconsax.play, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      isDisabled ? 'قيد التطوير' : 'بدء تطبيق المقياس',
                      style: const TextStyle(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'تقييم التوحد عن طريق تطبيق المقاييس',
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
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.chart_square,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'المقاييس المتاحة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildTestCard(
                context: context,
                title: 'M-CHAT',
                subtitle: 'فحص التوحد المعدل للأطفال الصغار',
                description:
                    'أداة فحص مبكر سريعة وفعالة للكشف عن علامات التوحد. يركز على السلوكيات الأساسية والتفاعل الاجتماعي.',
                icon: Iconsax.user_cirlce_add,
                color: AppColors.primary,
                testType: 'mchat',
              ),

              _buildTestCard(
                context: context,
                title: 'CARS-2 + M-CHAT',
                subtitle: 'الاختبار المدمج الشامل',
                description:
                    'يجمع بين قوة مقياس CARS-2 ومقياس M-CHAT لتقييم شامل وأكثر دقة لطيف التوحد.',
                icon: Iconsax.diagram,
                color: AppColors.accent,
                testType: 'cars_mchat',
              ),

              _buildTestCard(
                context: context,
                title: 'GARS-3',
                subtitle: 'مقياس جيليام لتقييم التوحد',
                description:
                    'مقياس متقدم يقيم السلوكيات النمطية، التواصل، والتفاعل الاجتماعي بطريقة شاملة ومفصلة.',
                icon: Iconsax.chart_2,
                color: AppColors.secondary,
                testType: 'gars3',
                isDisabled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
