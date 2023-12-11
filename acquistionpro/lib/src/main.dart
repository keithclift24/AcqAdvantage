import 'package:flutter/material.dart';

void main() {
  runApp(const AcquisitionProApp());
}

class AcquisitionProApp extends StatelessWidget {
  const AcquisitionProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acquisition Pro',
      theme: ThemeData(
        // Define your app's color scheme here
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Acquisition Pro'),
      ),
      body: const Center(
        child: Text('Login Page Content Goes Here'),
      ),
    );
  }
}