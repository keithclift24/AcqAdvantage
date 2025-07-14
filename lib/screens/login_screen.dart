import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image container covering entire screen
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Center widget with login form
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(32.0),
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo
                              Image.asset(
                                'assets/images/acqadvantagelogotransparent.png',
                              ),
                              const SizedBox(height: 16.0),

                              // Title
                              const Text(
                                'ACCOUNT LOGIN',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // Email TextField
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // Password TextField
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // Login Button
                              ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        final authProvider =
                                            Provider.of<AuthProvider>(context,
                                                listen: false);
                                        final success =
                                            await authProvider.loginWithEmail(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                        );

                                        if (mounted) {
                                          if (success) {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeScreen(),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    authProvider.errorMessage ??
                                                        'Login failed'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text('Login'),
                              ),
                              const SizedBox(height: 16.0),

                              // Google Connect Button
                              OutlinedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        final authProvider =
                                            Provider.of<AuthProvider>(context,
                                                listen: false);
                                        final success = await authProvider
                                            .loginWithGoogle();

                                        if (mounted) {
                                          if (success) {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeScreen(),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    authProvider.errorMessage ??
                                                        'Google login failed'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                child: authProvider.isLoading
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 8.0),
                                          Text('Connecting...'),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/google_icon.png',
                                            height: 24.0,
                                            width: 24.0,
                                          ),
                                          const SizedBox(width: 8.0),
                                          const Text('Connect with Google'),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Loading overlay
                  if (authProvider.isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
