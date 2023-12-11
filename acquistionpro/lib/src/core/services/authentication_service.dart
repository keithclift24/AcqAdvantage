import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:acquisitionpro/src/core/models/user.dart';

class AuthenticationService {
  // Replace with your actual REST API endpoint
  final String _baseUrl = 'https://yourapi.com/auth';

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return User.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw LoginException('Failed to login. Status code: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    // Implement logout logic, possibly including a network request to inform the backend
  }
}

class LoginException implements Exception {
  final String message;
  LoginException(this.message);

  @override
  String toString() => 'LoginException: $message';
}