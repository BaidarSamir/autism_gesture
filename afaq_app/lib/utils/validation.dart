class Validation {
  static bool isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'كلمة المرور مطلوبة';
    if (password.length < 8) {
      return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
    }
    return null;
  }

  static String? validateChildName(String name) {
    final regex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]{2,30}$');
    if (name.isEmpty) return 'اسم الطفل مطلوب';
    if (!regex.hasMatch(name)) {
      return 'يرجى إدخال اسم صحيح (بالحروف فقط)';
    }
    return null;
  }
}
