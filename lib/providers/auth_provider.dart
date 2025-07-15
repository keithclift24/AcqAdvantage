import 'package:flutter/foundation.dart';
import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class AuthProvider extends ChangeNotifier {
  BackendlessUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Public getters
  BackendlessUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // Conditional initialization based on platform
    if (kIsWeb) {
      // Web initialization using JavaScript API key
      Backendless.initApp(
        applicationId: "0EB3F73D-1225-30F9-FFB8-CFD226E65F00",
        customDomain: "toughquilt.backendless.app",
        androidApiKey: "0FF7C923-0152-4765-9CFC-05EE6D697A14",
      );
    } else {
      // Mobile initialization using Android API key
      Backendless.initApp(
        applicationId: "0EB3F73D-1225-30F9-FFB8-CFD226E65F00",
        customDomain: "toughquilt.backendless.app",
        androidApiKey: "AEA2107E-C9A9-416E-B13A-F6797EEAB4DE",
      );
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await Backendless.userService
          .login(email, password, stayLoggedIn: true);
      _currentUser = user;
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
      debugPrint('Creating checkout session for plan type: $planType');

      // Get user token from Backendless
      final userToken = await Backendless.userService.getUserToken();
      debugPrint('User token retrieved: ${userToken != null ? 'Yes' : 'No'}');

      if (userToken == null || _currentUser == null) {
        debugPrint(
            'User not authenticated - userToken: $userToken, currentUser: $_currentUser');
        throw Exception('User not authenticated');
      }

      final objectId = _currentUser!.getProperty('objectId');
      debugPrint('User objectId: $objectId');

      // Make POST request to create checkout session
      debugPrint('Making POST request to API...');
      final response = await http.post(
        Uri.parse(
            'https://acqadvantage-api.onrender.com/create-checkout-session'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user-token': userToken,
          'objectId': objectId,
          'planType': planType,
        }),
      );

      debugPrint('API response status: ${response.statusCode}');
      debugPrint('API response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final sessionId = responseData['sessionId'];
        debugPrint('Received sessionId from API: $sessionId');

        // Launch Stripe checkout URL
        final checkoutUrl = 'https://checkout.stripe.com/pay/$sessionId';
        final uri = Uri.parse(checkoutUrl);
        debugPrint('Launching Stripe checkout URL: $checkoutUrl');

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          debugPrint('Stripe checkout URL launched successfully');
        } else {
          debugPrint('Could not launch checkout URL: $checkoutUrl');
          throw Exception('Could not launch checkout URL');
        }
      } else {
        debugPrint(
            'Failed to create checkout session - Status: ${response.statusCode}, Body: ${response.body}');
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
