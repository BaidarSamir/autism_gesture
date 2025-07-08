import 'package:autism_screener/services/auth_service.dart';
import 'package:autism_screener/state/bloc/auth_event.dart';
import 'package:autism_screener/state/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService})
    : super(const AuthInitial(isLoading: false)) {
    on<AppStarted>(_onAuthInitializeRequested);
    on<LoginSubmitted>(_onSignInRequested);
    on<RegisterSubmitted>(_onSignUpRequested);
    on<LogoutPressed>(_onSignOutRequested);
    on<ForgotPasswordSubmitted>(_onResetPasswordRequested);
  }

  Future<void> _onAuthInitializeRequested(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthInitial(isLoading: true));

      final currentUser = await authService.getCurrentUser();

      if (currentUser != null) {
        emit(AuthAuthenticated(user: currentUser, isLoading: false));
      } else {
        emit(const AuthUnauthenticated(isLoading: false));
      }
    } on Exception catch (e) {
      emit(AuthUnauthenticated(exception: e, isLoading: false));
    } catch (e) {
      emit(
        AuthUnauthenticated(
          exception: Exception('فشل في التحقق من حالة المصادقة'),
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onSignInRequested(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthSigningIn(isLoading: true));

      final user = await authService.signIn(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated(user: user!, isLoading: false));
    } on Exception catch (e) {
      emit(AuthUnauthenticated(exception: e, isLoading: false));
    } catch (_) {
      emit(
        AuthUnauthenticated(
          exception: Exception(
            'حدث خطأ أثناء تسجيل الدخول. يرجى المحاولة مرة أخرى',
          ),
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onSignUpRequested(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthRegistering(isLoading: true));

      final user = await authService.signUp(
        email: event.email,
        password: event.password,
        childName: event.childName,
      );

      emit(AuthAuthenticated(user: user!, isLoading: false));
    } on Exception catch (e) {
      emit(AuthUnauthenticated(exception: e, isLoading: false));
    } catch (_) {
      emit(
        AuthUnauthenticated(
          exception: Exception(
            'حدث خطأ أثناء إنشاء الحساب. يرجى المحاولة مرة أخرى',
          ),
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    LogoutPressed event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthSigningOut(isLoading: true));

      await authService.signOut();

      emit(const AuthUnauthenticated(isLoading: false));
    } on Exception catch (e) {
      emit(AuthUnauthenticated(exception: e, isLoading: false));
    } catch (_) {
      emit(
        AuthUnauthenticated(
          exception: Exception(
            'حدث خطأ أثناء تسجيل الخروج. يرجى المحاولة مرة أخرى',
          ),
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onResetPasswordRequested(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthResettingPassword(isLoading: true));

      await authService.resetPassword(event.email);
      emit(const AuthUnauthenticated(isLoading: false));
    } on Exception catch (e) {
      emit(AuthUnauthenticated(exception: e, isLoading: false));
    } catch (_) {
      emit(
        AuthUnauthenticated(
          exception: Exception(
            'حدث خطأ أثناء إرسال رابط إعادة تعيين كلمة المرور. يرجى المحاولة مرة أخرى',
          ),
          isLoading: false,
        ),
      );
    }
  }
}
