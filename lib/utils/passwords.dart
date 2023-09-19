import 'dart:math';

class PasswordManager {
  static int checkStrength(String password) {
    int strength = 0, percentage = 0;
    int totalCriteria = 5;

    bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    bool hasDigit = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecialChar =
        RegExp(r'[!@#\+\-$%^&*(),.?":{}|<>]').hasMatch(password);

    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasDigit) strength++;
    if (hasSpecialChar) strength++;
    if (password.length >= 8) strength++;

    percentage = (strength / totalCriteria * 100).toInt();

    return percentage;
  }

  static String strengthenPassword(String password) {
    bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    bool hasDigit = RegExp(r'\d').hasMatch(password);
    bool hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);

    Random random = Random();

    while (password.length < 8 ||
        !hasUpperCase ||
        !hasLowerCase ||
        !hasDigit ||
        !hasSpecialChar) {
      int randomType = random.nextInt(
          4); // 0 for uppercase, 1 for lowercase, 2 for digit, 3 for special char
      switch (randomType) {
        case 0:
          password += String.fromCharCode(
              random.nextInt(26) + 65); // Random uppercase letter
          break;
        case 1:
          password += String.fromCharCode(
              random.nextInt(26) + 97); // Random lowercase letter
          break;
        case 2:
          password += random.nextInt(10).toString(); // Random digit
          break;
        case 3:
          password += "!@#-\$%&"[random.nextInt(7)]; // Random special character
          break;
      }

      hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
      hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
      hasDigit = RegExp(r'\d').hasMatch(password);
      hasSpecialChar = RegExp(r'[!@#-$%&]').hasMatch(password);
    }

    return password;
  }
}
