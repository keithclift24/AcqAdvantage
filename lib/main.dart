import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() {
  Stripe.publishableKey =
      'pk_test_...'; // Placeholder for Stripe publishable key
  runApp(const AcqAdvantageApp());
}

class AcqAdvantageApp extends StatelessWidget {
  const AcqAdvantageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'AcqAdvantage',
        theme: appTheme,
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
