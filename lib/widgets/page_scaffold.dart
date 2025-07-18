import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PageScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white, // White text for good contrast
        actions: [
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 12),
              const SizedBox(width: 4),
              const Text('Logged In'),
              const SizedBox(width: 16),
              Text(
                authProvider.isSubscribed ? 'Subscribed' : 'Not Subscribed',
                style: TextStyle(
                  color: authProvider.isSubscribed ? Colors.green : Colors.red,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  authProvider.checkSubscriptionStatus();
                },
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
          body,
        ],
      ),
    );
  }
}
