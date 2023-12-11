import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acquisitionpro/src/core/providers/user_provider.dart';
import 'package:acquisitionpro/src/features/login/presentation/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid == true) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<UserProvider>(context, listen: false)
            .login(_emailController.text, _passwordController.text);
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to login: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Placeholder for the signup function
  void _signup() {
    // Implement your signup logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background color
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/acqprologo.png', width: 480, height: 480), // Logo size increased
                  const SizedBox(height: 48),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.black),
                            hintText: 'Enter your username',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                            ),
                            prefixIcon: Icon(Icons.person, color: Colors.black54),
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.black),
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.black54),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                )
                              : const Text('Login'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green, // Sign-up button color
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _isLoading ? null : _signup,
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}