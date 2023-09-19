import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _logged = false;
  bool _registered = false;

  bool get logged => _logged;
  bool get registered => _registered;

  setlogged(bool value) {
    _logged = value;
    notifyListeners();
  }

  setregistered(bool value) {
    _registered = value;
    notifyListeners();
  }
}
