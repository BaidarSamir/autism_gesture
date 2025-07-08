import 'package:autism_screener/models/parent.dart';
import 'package:autism_screener/services/auth_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService(this._firebaseAuth, [FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<bool> isSignedIn() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      return currentUser != null;
    } catch (e) {
      throw Exception('حدث خطأ أثناء التحقق من حالة المصادقة');
    }
  }

  @override
  Future<Parent?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('parents').doc(user.uid).get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return Parent(email: user.email!, childName: data['childName'] as String);
    } catch (e) {
      throw Exception('حدث خطأ أثناء جلب بيانات المستخدم');
    }
  }

  @override
  Future<Parent?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = _firebaseAuth.currentUser!;
      final doc = await _firestore.collection('parents').doc(user.uid).get();
      print(doc.data());

      if (!doc.exists) {
        throw Exception('بيانات المستخدم غير موجودة');
      }

      final data = doc.data() as Map<String, dynamic>;
      return Parent(email: user.email!, childName: data['childName'] as String);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('حدث خطأ غير متوقع أثناء تسجيل الدخول');
    }
  }

  @override
  Future<Parent?> signUp({
    required String email,
    required String password,
    required String childName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      await _firestore.collection('parents').doc(user.uid).set({
        'childName': childName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Parent(email: user.email!, childName: childName);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('حدث خطأ غير متوقع أثناء إنشاء الحساب');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseException catch (e) {
      throw Exception('حدث خطأ أثناء تسجيل الخروج: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع أثناء تسجيل الخروج');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع أثناء إعادة تعيين كلمة المرور');
    }
  }

  Exception _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'invalid-email':
        return InvalidEmailException();
      case 'user-disabled':
        return UserDisabledException();
      case 'user-not-found':
        return UserNotFoundException();
      case 'wrong-password':
        return WrongPasswordException();
      case 'email-already-in-use':
        return EmailAlreadyInUseException();
      case 'operation-not-allowed':
        return OperationNotAllowedException();
      case 'weak-password':
        return WeakPasswordException();
      case 'too-many-requests':
        return TooManyRequestsException();
      case 'network-request-failed':
        return NetworkRequestFailedException();
      default:
        return Exception('حدث خطأ: ${e.message ?? 'غير معروف'}');
    }
  }
}
