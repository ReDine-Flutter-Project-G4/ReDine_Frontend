import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redine_frontend/pages/app.dart';
import 'package:redine_frontend/pages/auth_page.dart';
import 'package:redine_frontend/pages/email_verification_page.dart'; // <- Import this

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        if (user != null) {
          if (user.emailVerified) {
            return const App();
          } else {
            return const EmailVerificationPage();
          }
        } else {
          return const AuthPage();
        }
      },
    );
  }
}
