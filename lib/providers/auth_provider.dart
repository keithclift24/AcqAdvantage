import 'package:flutter/foundation.dart';
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
    // Correct way to initialize with a custom domain for this SDK version
    Backendless.initApp(
      applicationId: "0EB3F73D-1225-30F9-FFB8-CFD226E65F00",
      customDomain: "toughquilt.backendless.app", // THE FIX
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
      final userToken = await Backendless.userService.getUserToken();
      if (userToken != null) {
        await _secureStorage.write(key: 'user-token', value: userToken);
      }
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
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
      final userService = Backendless.userService as dynamic;
      final user = await userService.loginWithGoogle(true);

      if (user != null) {
        _currentUser = user;
        final userToken = await Backendless.userService.getUserToken();
        if (userToken != null) {
          await _secureStorage.write(key: 'user-token', value: userToken);
        }
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Google login failed: no user returned.');
      }
    } catch (e) {
      debugPrint('Google login error: $e');
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
      final newUser = BackendlessUser()
        ..email = email
        ..password = password;
      await Backendless.userService.register(newUser);
      return await loginWithEmail(email, password);
    } catch (e) {
      debugPrint('Registration error: $e');
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
      debugPrint('Logout error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} // <-- The missing closing brace
