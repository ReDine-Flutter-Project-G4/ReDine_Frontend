import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:redine_frontend/pages/auth_page.dart';
import '../pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return const HomeTabPage(); // authenticated
        } else {
          return const AuthPage(); // not logged in
        }
      },
    );
  }
}
