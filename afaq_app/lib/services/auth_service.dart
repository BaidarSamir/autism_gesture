import 'package:autism_screener/models/parent.dart';

abstract class AuthService {
  Future<bool> isSignedIn();

  Future<Parent?> signIn({required String email, required String password});

  Future<Parent?> signUp({
    required String email,
    required String password,
    required String childName,
  });

  Future<void> signOut();

  Future<void> resetPassword(String email);
  Future<Parent?> getCurrentUser();
}
