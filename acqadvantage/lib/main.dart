import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acquisitionpro/src/core/providers/user_provider.dart';
import 'package:acquisitionpro/src/features/login/presentation/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the firebase_options.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Pass the Firebase options
  );
  runApp(const AcquisitionProApp());
}

class AcquisitionProApp extends StatelessWidget {
  const AcquisitionProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Add other providers here if you have any
      ],
      child: MaterialApp(
        title: 'Acquisition Pro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const LoginScreen(), // Your login screen widget
      ),
    );
  }
}