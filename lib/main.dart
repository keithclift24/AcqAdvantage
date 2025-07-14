import 'package:acqadvantage/theme.dart'; // Correctly imported already! 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:acquisitionpro/src/core/providers/user_provider.dart'; // Change path if project name differs
// import 'package:acquisitionpro/src/features/login/presentation/login_screen.dart'; // Change path if project name differs
// Consider renaming 'acquisitionpro' parts if this is a new project setup

// Let's adjust these imports based on our consistent project name: 'acqadvantage'
// Assuming your LoginScreen is now in 'lib/screens/login_screen.dart' as per our plan
import 'package:acqadvantage/src/core/providers/auth_provider.dart'; // Assuming you will have an AuthProvider soon
import 'package:acqadvantage/screens/login_screen.dart'; // This path is more common for initial setup

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the firebase_options.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Pass the Firebase options
  );
  runApp(const AcqAdvantageApp()); // Renamed for consistency
}

class AcqAdvantageApp extends StatelessWidget { // Renamed for consistency
  const AcqAdvantageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Placeholder for AuthProvider which we will create in Step 2.3
        ChangeNotifierProvider(create: (_) => AuthProvider()), // We'll build this in Step 2.3
        // You can keep UserProvider if it serves a distinct purpose from AuthProvider
        // ChangeNotifierProvider(create: (_) => UserProvider()),
        // Add other providers here if you have any
      ],
      child: MaterialApp(
        title: 'AcqAdvantage', // Updated title for consistency
        theme: appTheme, // <--- **CRITICAL CHANGE: Applying our custom theme** 
        // visualDensity is fine to keep, but it's part of appTheme now.
        // ThemeData(primarySwatch: Colors.blue...) is replaced by appTheme
        home: const LoginScreen(), // Your login screen widget
      ),
    );
  }
}