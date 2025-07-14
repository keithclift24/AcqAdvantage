import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:acqadvantage/providers/auth_provider.dart';
import 'package:acqadvantage/screens/login_screen.dart';
import 'package:acqadvantage/theme.dart';

void main() {
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
