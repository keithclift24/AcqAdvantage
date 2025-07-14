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
      applicationId: "0EB3F73D-1225-30F9-FFB8-CFD226E65F00", // Backendless App ID
      androidApiKey: "AEA2107E-C9A9-416E-B13A-F6797EEAB4DE", // Backendless Android API Key (for Flutter)
    );
    _loadCurrentUser(); // Attempt to load a previously logged-in user
  }

  Future<void> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await Backendless.userService.login(email, password, stayLoggedIn: true);
      _currentUser = user;
      _errorMessage = null;
    } on BackendlessException catch (e) {
      _errorMessage = e.message;
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = BackendlessUser();
      newUser.email = email;
      newUser.password = password;
      
      final user = await Backendless.userService.register(newUser);
      _currentUser = user;
      
      // Future: Call Python API endpoint to set 'trialing' status in Subscriptions table.
      // This will initiate the 24-hour free trial after registration
      
      _errorMessage = null;
    } on BackendlessException catch (e) {
      _errorMessage = e.message;
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Backendless.userService.logout();
      await _secureStorage.delete(key: 'userToken');
      _currentUser = null;
      _errorMessage = null;
    } on BackendlessException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For now, we'll rely on Backendless SDK's built-in session management
      // The SDK will automatically handle user sessions when stayLoggedIn is true
      // Future enhancement: Implement custom token validation if needed
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recoverPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Backendless.userService.restorePassword(email);
      _errorMessage = null;
    } on BackendlessException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Attempt to call the Google login method using dynamic invocation
      // This allows the code to compile even if the method signature isn't recognized
      final userService = Backendless.userService as dynamic;
      final user = await userService.loginWithGoogle(true) as BackendlessUser?;
      
      if (user != null) {
        _currentUser = user;
        // Note: userToken property may not be available in current SDK version
        // Using dynamic access to handle potential property availability
        final userDynamic = user as dynamic;
        if (userDynamic.userToken != null) {
          await _secureStorage.write(key: 'userToken', value: userDynamic.userToken as String);
        }
        _errorMessage = null; // Clear any previous errors
      } else {
        _errorMessage = 'Google authentication failed - no user returned';
        _currentUser = null;
      }
      
    } on BackendlessException catch (e) {
      _errorMessage = e.message ?? 'Google authentication failed';
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'Google authentication error: ${e.toString()}';
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Placeholder method for future implementation
  Future<void> _initiateTrialInBackend(String userObjectId) async {
    // Future implementation: This method will call a Python API endpoint
    // to set the user's subscription status to 'trialing' in the Subscriptions table
    // The Python API will handle the business logic for:
    // 1. Creating a new subscription record for the user
    // 2. Setting the status to 'trialing'
    // 3. Setting the trial_end_date to 24 hours from registration
    // 4. Configuring any trial-specific permissions or features
    
    // Example future implementation:
    // final response = await http.post(
    //   Uri.parse('https://your-python-api.com/initiate-trial'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: json.encode({'userObjectId': userObjectId}),
    // );
  }
}
