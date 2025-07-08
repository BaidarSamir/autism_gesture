import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogoutPressed extends AuthEvent {
  const LogoutPressed();
}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String childName;

  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.childName,
  });

  @override
  List<Object> get props => [email, password, childName];
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;

  const ForgotPasswordSubmitted({required this.email});

  @override
  List<Object> get props => [email];
}
