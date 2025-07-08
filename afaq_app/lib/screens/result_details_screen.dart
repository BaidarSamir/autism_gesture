import 'package:autism_screener/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';

class ResultDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultDetailsScreen({Key? key, required this.result}) : super(key: key);

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'بسيط':
        return AppColors.success;
      case 'متوسط':
        return AppColors.warning;
      case 'شديد':
        return AppColors.error;
      default:
        return AppColors.textDisabled;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'بسيط':
        return Iconsax.tick_circle;
      case 'متوسط':
        return Iconsax.warning_2;
      case 'شديد':
        return Iconsax.danger;
      default:
        return Iconsax.info_circle;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final testType = result['testType'] ?? 'غير محدد';
    final riskLevel = result['riskLevel'] ?? 'غير محدد';
    final score = result['score'];
    final maxScore = result['maxScore'];
    final dynamic timestampRaw = result['timestamp'];

    final DateTime? timestamp = timestampRaw is Timestamp
        ? timestampRaw.toDate()
        : timestampRaw is DateTime
        ? timestampRaw
        : null;
    final primaryGesture = result['primaryGesture'];
    final confidence = result['confidence'];
    final rawConfidences =
        result['detailedConfidences'] as Map<String, dynamic>? ?? {};
    final detailedConfidences = rawConfidences.map<String, double>(
      (key, value) => MapEntry(key, value.toDouble()),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'تفاصيل النتيجة',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getRiskColor(
                                  riskLevel,
                                ).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                testType.contains('فيديو') ||
                                        primaryGesture != null
                                    ? Iconsax.video
                                    : Iconsax.health,
                                color: _getRiskColor(riskLevel),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              testType,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (timestamp != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatDate(timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (primaryGesture != null && confidence != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الحركة المكتشفة: ${() {
                              switch (primaryGesture) {
                                case 'HeadBanging':
                                  return 'تحريك الرأس';
                                case 'Spinning':
                                  return 'الدوران';
                                case 'ArmFlapping':
                                  return 'رفرفة الذراع';
                                default:
                                  return 'غير معروفة';
                              }
                            }()}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _getRiskColor(riskLevel),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Iconsax.chart_2,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'الثقة: ${(confidence * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else if (score != null && maxScore != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            riskLevel,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _getRiskColor(riskLevel),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Iconsax.document,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'النتيجة: $score/$maxScore',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getRiskColor(riskLevel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getRiskColor(riskLevel).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getRiskColor(riskLevel).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getRiskIcon(riskLevel),
                        color: _getRiskColor(riskLevel),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'مستوى الخطورة: $riskLevel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(riskLevel),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (detailedConfidences.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'التفاصيل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...detailedConfidences.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: entry.value > 0.5
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                () {
                                  switch (entry.key) {
                                    case 'HeadBanging':
                                      return Iconsax.user;
                                    case 'Spinning':
                                      return Iconsax.rotate_right;
                                    case 'ArmFlapping':
                                      return Iconsax.activity;
                                    default:
                                      return Iconsax.activity;
                                  }
                                }(),
                                size: 18,
                                color: entry.value > 0.5
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                () {
                                  switch (entry.key) {
                                    case 'HeadBanging':
                                      return 'تحريك الرأس';
                                    case 'Spinning':
                                      return 'الدوران';
                                    case 'ArmFlapping':
                                      return 'رفرفة الذراع';
                                    default:
                                      return '';
                                  }
                                }(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: entry.value > 0.5
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${(entry.value * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: entry.value > 0.5
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.arrow_right_3, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'العودة للنتائج السابقة',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
