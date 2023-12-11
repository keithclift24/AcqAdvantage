import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/authentication_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthenticationService _authService = AuthenticationService();

  User? get user => _user;

  Future<void> login(String email, String password) async {
    _user = await _authService.login(email, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}