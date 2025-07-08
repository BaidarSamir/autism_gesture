class AuthException implements Exception {
  final String message;

  AuthException(this.message);
}

class InvalidEmailException extends AuthException {
  InvalidEmailException() : super('البريد الإلكتروني غير صالح');
}

class UserDisabledException extends AuthException {
  UserDisabledException() : super('هذا الحساب معطل. يرجى التواصل مع الدعم الفني');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException() : super('لا يوجد حساب مرتبط بهذا البريد الإلكتروني');
}

class WrongPasswordException extends AuthException {
  WrongPasswordException() : super('كلمة المرور غير صحيحة');
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException() : super('هذا البريد الإلكتروني مستخدم بالفعل');
}

class OperationNotAllowedException extends AuthException {
  OperationNotAllowedException()
      : super('عملية تسجيل الدخول غير مسموح بها. يرجى التواصل مع الدعم الفني');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException()
      : super('كلمة المرور ضعيفة. يرجى اختيار كلمة مرور أقوى');
}

class TooManyRequestsException extends AuthException {
  TooManyRequestsException()
      : super('عدد كبير جدًا من الطلبات. يرجى المحاولة مرة أخرى لاحقًا');
}

class NetworkRequestFailedException extends AuthException {
  NetworkRequestFailedException()
      : super('فشل في الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت');
}