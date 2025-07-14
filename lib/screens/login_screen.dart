import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acquisitionpro/src/core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                    child: Container(
                      width: 360.0,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Image.asset(
                              'assets/images/acqadvantagelogotransparent.png',
                              height: 200.0,
                            ),
                            const SizedBox(height: 24.0),
                            
                            // Title
                            Text(
                              'ACCOUNT LOGIN',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            
                            // Email TextField
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            
                            // Password TextField
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading ? null : () async {
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  await authProvider.loginWithEmail(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );
                                  
                                  if (mounted) {
                                    if (authProvider.errorMessage != null) {
                                      // Show error message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(authProvider.errorMessage!),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else if (authProvider.isAuthenticated) {
                                      // TODO: Navigate to home screen
                                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login successful!'),
                                          backgroundColor: Colors.green,
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Login'),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            
                            // Forgot Password Button
                            TextButton(
                              onPressed: authProvider.isLoading ? null : () async {
                                if (_emailController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter your email address first'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                await authProvider.recoverPassword(_emailController.text.trim());
                                
                                if (mounted) {
                                  if (authProvider.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(authProvider.errorMessage!),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password recovery email sent!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            
                            // Google Connect Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: authProvider.isLoading ? null : () async {
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  await authProvider.loginWithGoogle();
                                  
                                  if (mounted) {
                                    if (authProvider.errorMessage != null) {
                                      // Show error message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(authProvider.errorMessage!),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else if (authProvider.isAuthenticated) {
                                      // TODO: Navigate to home screen
                                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Google login successful!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  foregroundColor: Colors.white,
                                ),
                                child: authProvider.isLoading 
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Text('Connecting...'),
                                      ],
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login, size: 24.0), // Placeholder for Google icon
                                        SizedBox(width: 8.0),
                                        Text('Connect with Google'),
                                      ],
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            
                            // Sign Up Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                TextButton(
                                  onPressed: authProvider.isLoading ? null : () async {
                                    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please enter both email and password'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    
                                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                    await authProvider.registerWithEmail(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    );
                                    
                                    if (mounted) {
                                      if (authProvider.errorMessage != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(authProvider.errorMessage!),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } else if (authProvider.isAuthenticated) {
                                        // TODO: Navigate to home screen or show welcome message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Registration successful! Welcome!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
