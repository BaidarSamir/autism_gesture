import 'dart:io';
import 'dart:convert';
import 'package:autism_screener/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autism_screener/screens/result_details_screen.dart';
import 'package:iconsax/iconsax.dart';

class GestureResult {
  final String primaryGesture;
  final double primaryConfidence;
  final Map<String, double> detailedConfidences;

  GestureResult({
    required this.primaryGesture,
    required this.primaryConfidence,
    required this.detailedConfidences,
  });

  factory GestureResult.fromJson(Map<String, dynamic> json) {
    return GestureResult(
      primaryGesture: json['primary_gesture'] ?? 'None',
      primaryConfidence: (json['primary_confidence'] ?? 0.0).toDouble(),
      detailedConfidences: Map<String, double>.from(
        (json['detailed_confidences'] as Map).map(
          (key, value) => MapEntry(key, value.toDouble()),
        ),
      ),
    );
  }
}

class VideoDiagnosisScreen extends StatefulWidget {
  const VideoDiagnosisScreen({Key? key}) : super(key: key);

  @override
  State<VideoDiagnosisScreen> createState() => _VideoDiagnosisScreenState();
}

class _VideoDiagnosisScreenState extends State<VideoDiagnosisScreen>
    with TickerProviderStateMixin {
  File? _selectedVideo;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _previousVideoResults = [];
  late AnimationController _pulseController;
  late AnimationController _slideController;

  final serverUrl = dotenv.env['SERVER_URL'];
  @override
  void initState() {
    super.initState();
    _loadPreviousVideoResults();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadPreviousVideoResults() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('diagnosis_results')
            .where('userId', isEqualTo: user.uid)
            .where('testType', isEqualTo: 'التشخيص بالفيديو - تحليل الحركات')
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();

        setState(() {
          _previousVideoResults = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
      }
    } catch (e) {
      print('Error loading previous video results: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedVideo = File(result.files.single.path!);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في اختيار الفيديو: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadAndAnalyzeVideo() async {
    if (_selectedVideo == null) {
      setState(() {
        _errorMessage = 'يرجى اختيار فيديو أولاً';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$serverUrl/predict'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedVideo!.path,
          filename: basename(_selectedVideo!.path),
        ),
      );

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(respStr);
        final result = GestureResult.fromJson(jsonResponse);

        await _saveResultToFirebase(result);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في تحليل الفيديو: ${e.toString()}';
      });
    }
  }

  Future<void> _saveResultToFirebase(GestureResult result) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String riskLevel = _calculateRiskLevel(result);
        final DocumentReference docRef = await FirebaseFirestore.instance
            .collection('diagnosis_results')
            .add({
              'userId': user.uid,
              'testType': 'التشخيص بالفيديو - تحليل الحركات',
              'primaryGesture': _translateGesture(result.primaryGesture),
              'confidence': result.primaryConfidence,
              'detailedConfidences': result.detailedConfidences.map(
                (key, value) => MapEntry(_translateGesture(key), value),
              ),
              'riskLevel': riskLevel,
              'timestamp': FieldValue.serverTimestamp(),
              'analysisType': 'video_gesture_analysis',
            });

        final DocumentSnapshot snapshot = await docRef.get();
        final resultData = snapshot.data() as Map<String, dynamic>;
        final resultWithId = {'id': snapshot.id, ...resultData};

        if (mounted) {
          Navigator.push(
            this.context,
            MaterialPageRoute(
              builder: (context) => ResultDetailsScreen(result: resultWithId),
            ),
          ).then((_) {
            setState(() {
              _isLoading = false;
              _selectedVideo = null;
            });
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.push(
          this.context,
          MaterialPageRoute(
            builder: (context) => ResultDetailsScreen(
              result: {
                'primaryGesture': _translateGesture(result.primaryGesture),
                'confidence': result.primaryConfidence,
                'detailedConfidences': result.detailedConfidences.map(
                  (key, value) => MapEntry(_translateGesture(key), value),
                ),
                'riskLevel': _calculateRiskLevel(result),
                'timestamp': DateTime.now(),
                'testType': 'التشخيص بالفيديو - تحليل الحركات',
              },
            ),
          ),
        ).then((_) {
          setState(() {
            _isLoading = false;
            _selectedVideo = null;
          });
        });
      }
    }
  }

  String _calculateRiskLevel(GestureResult result) {
    final gesture = result.primaryGesture.toLowerCase();
    final confidence = result.primaryConfidence;

    if (gesture.contains('stimming') || gesture.contains('repetitive')) {
      if (confidence > 0.7) return 'شديد';
      if (confidence > 0.4) return 'متوسط';
      return 'بسيط';
    } else if (gesture.contains('pointing') || gesture.contains('waving')) {
      if (confidence > 0.7) return 'بسيط';
      if (confidence > 0.4) return 'متوسط';
      return 'شديد';
    } else {
      return 'متوسط';
    }
  }

  String _translateGesture(String gesture) {
    const translations = {
      'pointing': 'الإشارة',
      'waving': 'التلويح',
      'clapping': 'التصفيق',
      'stimming': 'التحفيز الذاتي',
      'repetitive_movement': 'الحركة المتكررة',
      'none': 'لا توجد حركة',
    };
    return translations[gesture.toLowerCase()] ?? gesture;
  }

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

  Widget _buildInstructionsCard() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutBack,
            ),
          ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                const Expanded(
                  child: Text(
                    'تعليمات التصوير',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._buildInstructionItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInstructionItems() {
    final instructions = [
      {'icon': Iconsax.eye, 'text': 'تأكد من وضوح الطفل في الفيديو'},
      {'icon': Iconsax.lamp, 'text': 'اجعل الإضاءة جيدة ومناسبة'},
      {'icon': Iconsax.timer, 'text': 'صور لمدة 30 ثانية على الأقل'},
      {'icon': Iconsax.finger_cricle, 'text': 'ركز على حركات اليدين والجسم'},
      {'icon': Iconsax.volume_slash, 'text': 'تجنب الضوضاء والحركة في الخلفية'},
    ];

    return instructions.asMap().entries.map((entry) {
      final index = entry.key;
      final instruction = entry.value;

      return AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _slideController.value) * (index + 1) * 20),
            child: Opacity(
              opacity: _slideController.value,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        instruction['icon'] as IconData,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        instruction['text'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.4,
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
    }).toList();
  }

  Widget _buildVideoSelectionButton() {
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
          onTap: _pickVideo,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.video, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'اختيار فيديو',
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

  Widget _buildSelectedVideoCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.success.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Iconsax.tick_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'تم اختيار الفيديو بنجاح',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.document,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    basename(_selectedVideo!.path),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildAnalyzeButton(),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isLoading
              ? [AppColors.textDisabled, AppColors.textDisabled]
              : [AppColors.success, AppColors.success.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_isLoading ? AppColors.textDisabled : AppColors.success)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _uploadAndAnalyzeVideo,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(Iconsax.scan, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  _isLoading ? 'جاري التحليل...' : 'تحليل الفيديو',
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget _buildLoadingCard() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.surfaceVariant],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                    ),
                    child: const Icon(
                      Iconsax.scan,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: _pulseController.value,
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary.withOpacity(0.6),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'جاري تحليل الفيديو...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'قد يستغرق هذا بضع دقائق، يرجى الانتظار',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withOpacity(0.1),
            AppColors.error.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Iconsax.warning_2, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Iconsax.clock, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'النتائج السابقة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _previousVideoResults.length,
          itemBuilder: (context, index) {
            final result = _previousVideoResults[index];
            return _buildResultCard(result, index);
          },
        ),
      ],
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, int index) {
    final testType = result['testType'] ?? 'غير محدد';
    final riskLevel = result['riskLevel'] ?? 'غير محدد';
    final primaryGesture = result['primaryGesture'];
    final confidence = result['confidence'];
    final timestamp = result['timestamp'] as Timestamp?;
    final riskColor = _getRiskColor(riskLevel);

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideController.value) * (index + 1) * 30),
          child: Opacity(
            opacity: _slideController.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.surface, AppColors.surfaceVariant],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: riskColor.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: riskColor.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/result_details',
                      arguments: result,
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [riskColor, riskColor.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: riskColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Iconsax.video_play,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                testType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.finger_cricle,
                                    size: 16,
                                    color: riskColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'الحركة: $primaryGesture',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: riskColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (confidence != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Iconsax.chart,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'الثقة: ${(confidence * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (timestamp != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Iconsax.calendar,
                                      size: 16,
                                      color: AppColors.textDisabled,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(timestamp.toDate()),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textDisabled,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Iconsax.arrow_right_3,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'التشخيص بالفيديو',
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
                  _buildInstructionsCard(),
                  const SizedBox(height: 24),
                  _buildVideoSelectionButton(),
                  const SizedBox(height: 20),
                  if (_selectedVideo != null) ...[
                    _buildSelectedVideoCard(),
                    const SizedBox(height: 24),
                  ],
                  if (_isLoading) ...[
                    _buildLoadingCard(),
                    const SizedBox(height: 24),
                  ],
                  if (_errorMessage != null) ...[
                    _buildErrorCard(),
                    const SizedBox(height: 24),
                  ],
                  if (_previousVideoResults.isNotEmpty) ...[
                    _buildPreviousResultsSection(),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
}
