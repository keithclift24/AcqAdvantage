import 'package:flutter/foundation.dart'; // Import this for debugPrint
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
    // CORRECTED INITIALIZATION
    Backendless.initApp(
      applicationId: "0EB3F73D-1225-30F9-FFB8-CFD226E65F00",
      androidApiKey: "AEA2107E-C9A9-416E-B13A-F6797EEAB4DE",
      serverUrl: "https://toughquilt.backendless.app", // THE FIX
    );
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await Backendless.userService.login(email, password, true);
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

  // CORRECTED GOOGLE LOGIN
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await Backendless.userService.loginWithOAuth2(
        'googleplus',
        {},
        true,
      );

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
      final user = await Backendless.userService.register(newUser);
      _currentUser = user;
      // You can now log the user in to get a token after registration
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

  // Other methods like recoverPassword can remain as you had them
}
