import 'package:autism_screener/models/parent.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  final bool isLoading;
  final Parent? currentUser;
  final Exception? exception;

  const AuthState({required this.isLoading, this.currentUser, this.exception});

  @override
  List<Object?> get props => [isLoading, currentUser, exception];
}

class AuthInitial extends AuthState {
  const AuthInitial({required super.isLoading});
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required Parent user, required super.isLoading})
    : super(currentUser: user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({super.exception, required super.isLoading});
}

class AuthSigningIn extends AuthState {
  const AuthSigningIn({super.exception, required super.isLoading});
}

class AuthRegistering extends AuthState {
  const AuthRegistering({super.exception, required super.isLoading});
}

class AuthSigningOut extends AuthState {
  const AuthSigningOut({super.exception, required super.isLoading});
}

class AuthResettingPassword extends AuthState {
  const AuthResettingPassword({super.exception, required super.isLoading});
}
