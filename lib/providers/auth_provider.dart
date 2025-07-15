import 'package:flutter/foundation.dart';
import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> createCheckoutSession(String planType) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Get user token from secure storage
      final userToken = await _secureStorage.read(key: 'user-token');

      if (userToken == null || _currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Make POST request to create checkout session
      final response = await http.post(
        Uri.parse(
            'https://acqadvantage-api.onrender.com/create-checkout-session'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user-token': userToken,
          'objectId': _currentUser!.getProperty('objectId'),
          'planType': planType,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final sessionId = responseData['sessionId'];

        // Launch Stripe checkout URL
        final checkoutUrl = 'https://checkout.stripe.com/pay/$sessionId';
        final uri = Uri.parse(checkoutUrl);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not launch checkout URL');
        }
      } else {
        throw Exception('Failed to create checkout session: ${response.body}');
      }

      _errorMessage = null;
    } catch (e) {
      debugPrint('Checkout session error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} // <-- The missing closing brace
