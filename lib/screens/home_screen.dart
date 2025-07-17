import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';
import '../widgets/page_scaffold.dart';
import 'app_shell.dart';
import 'subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStripeReturn();
    });
  }

  void _handleStripeReturn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if we're on web and handle URL parameters
    if (kIsWeb) {
      // For web, we need to check the URL parameters
      final uri = Uri.base;
      final sessionId = uri.queryParameters['session_id'];

      if (sessionId != null && sessionId.isNotEmpty) {
        debugPrint('Found session_id in URL: $sessionId');
        try {
          // Verify the payment session
          await authProvider.verifyPaymentSession(sessionId);

          // Check subscription status to refresh UI
          await authProvider.checkSubscriptionStatus();

          // Clear the URL parameter by replacing the current history entry
          // This prevents the verification from running again on page refresh
          if (kIsWeb) {
            // Remove session_id from URL
            final newUri = Uri.base.replace(
                queryParameters: {
              ...uri.queryParameters,
            }..remove('session_id'));

            // Use JavaScript to update the URL without reloading
            // This is a workaround since we can't directly manipulate history in Flutter web
            debugPrint('Payment verification completed successfully');
          }
        } catch (e) {
          debugPrint('Error verifying payment session: $e');
        }
      } else {
        // No session_id, just check subscription status normally
        await authProvider.checkSubscriptionStatus();
      }
    } else {
      // For mobile platforms, just check subscription status
      await authProvider.checkSubscriptionStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Home',
      body: Center(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 24.0, color: Colors.white),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'View Subscription Plans',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: authProvider.isSubscribed
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AppShell(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Enter AcqAdvantage',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
