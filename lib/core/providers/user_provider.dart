import 'package:flutter/foundation.dart';
import 'package:new_year_2025/core/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isValidated = false;

  User? get user => _user;
  bool get isValidated => _isValidated;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void validateUser(bool isValid) {
    _isValidated = isValid;
    notifyListeners();
  }
}
