import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/app_shell.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() {
  try {
    // Only initialize Stripe for mobile platforms
    if (!kIsWeb) {
      Stripe.publishableKey =
          'pk_test_51RjsS42Lfw5u3Q4QD4i0cJYE93KJRQTDae0Rhp7AhhMDqNttjRrHZts3zdPwf3lfbDGa8JtG0fhKvT6bDpw0T4DS00y1cCj1PV'; // Stripe publishable key
      debugPrint('Stripe initialized for mobile');
    } else {
      debugPrint('Skipping Stripe initialization for web');
    }
  } catch (e) {
    debugPrint('Error initializing Stripe: $e');
  }
  runApp(const AcqAdvantageApp());
}

class AcqAdvantageApp extends StatelessWidget {
  const AcqAdvantageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'AcqAdvantage',
        theme: appTheme,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.currentUser == null
                ? const LoginScreen()
                : const AppShell();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
