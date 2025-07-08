import 'package:autism_screener/screens/auth_flow_screen.dart';
import 'package:autism_screener/services/auth_service.dart';
import 'package:autism_screener/screens/result_details_screen.dart';
import 'package:autism_screener/screens/cars_mchat_question_screen.dart';
import 'package:autism_screener/screens/mchat_question_screen.dart';
import 'package:autism_screener/screens/scale_tests_screen.dart';
import 'package:autism_screener/screens/test_result_screen.dart';
import 'package:autism_screener/screens/video_diagnosis_screen.dart';
import 'package:autism_screener/services/firebase_auth_service.dart';
import 'package:autism_screener/state/bloc/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseConfig.firebaseOptions);
  final firebaseAuth = FirebaseAuth.instance;
  final authService = FirebaseAuthService(firebaseAuth);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authService: authService),
        ),
      ],
      child: MyApp(authService: authService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'NotoSansArabic'),
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthFlowScreen(),
      routes: {
        '/auth': (context) => const AuthFlowScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/scale_tests': (context) => const ScaleTestsScreen(),
        '/mchat_questions': (context) => MchatQuestionScreen(),
        '/test_result': (context) => const TestResultScreen(),
        '/cars_mchat_questions': (context) => const CarsMchatQuestionScreen(),
        '/video_diagnosis': (context) => const VideoDiagnosisScreen(),
        '/result_details': (context) => ResultDetailsScreen(
              result: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
            ),
      },
    );
  }
}