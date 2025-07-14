import 'package:flutter/material.dart';
import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  BackendlessUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Public getters
  BackendlessUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    Backendless.initApp(
      applicationId: "0EB3F73D-1225-30F9-FFB8-CFD226E65F00",
      androidApiKey: "AEA2107E-C9A9-416E-B13A-F6797EEAB4DE",
    );
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await Backendless.userService
          .login(email, password, stayLoggedIn: true);
      _currentUser = user;
      _errorMessage = null;

      // Get the user-token property from the returned user object
      final userDynamic = user as dynamic;
      if (userDynamic.userToken != null) {
        // Use FlutterSecureStorage to save the token with the key 'user-token'
        await _secureStorage.write(
            key: 'user-token', value: userDynamic.userToken as String);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use dynamic invocation to call the Google login method
      final userService = Backendless.userService as dynamic;
      final user = await userService.loginWithGoogle(true) as BackendlessUser;
      _currentUser = user;
      _errorMessage = null;

      // Get the user-token property from the returned user object
      final userDynamic = user as dynamic;
      if (userDynamic.userToken != null) {
        // Use FlutterSecureStorage to save the token with the key 'user-token'
        await _secureStorage.write(
            key: 'user-token', value: userDynamic.userToken as String);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newUser = BackendlessUser();
      newUser.email = email;
      newUser.password = password;

      final user = await Backendless.userService.register(newUser);
      _currentUser = user;
      _errorMessage = null;

      // Get the user-token property from the returned user object
      final userDynamic = user as dynamic;
      if (userDynamic.userToken != null) {
        // Use FlutterSecureStorage to save the token with the key 'user-token'
        await _secureStorage.write(
            key: 'user-token', value: userDynamic.userToken as String);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> recoverPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Backendless.userService.restorePassword(email);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Backendless.userService.logout();
      await _secureStorage.delete(key: 'user-token');
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      print(e);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
