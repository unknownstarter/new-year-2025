import 'package:flutter/foundation.dart';
import 'package:new_year_2025/core/models/user.dart';
import 'package:new_year_2025/core/services/fortune_service.dart';

class FortuneProvider with ChangeNotifier {
  final _fortuneService = FortuneService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> getFortune(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _fortuneService.getFortune(user);
      return result;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
