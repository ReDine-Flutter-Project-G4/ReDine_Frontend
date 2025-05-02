import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';
import 'package:redine_frontend/widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;
  bool _isLogin = true;

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF54AF75), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: Color(0xFF54AF75)),
    );
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signIn(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Passwords do not match')),
          );
          setState(() => _isLoading = false);
          return;
        }

        await _authService.register(
          _emailController.text,
          _passwordController.text,
          _usernameController.text
        );
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      if (!mounted) return;
      final errorMessage = _getFriendlyErrorMessage(e);
      messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _authService.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      if (!mounted) return;
      final message = _getFriendlyErrorMessage(e);
      messenger.showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $message')),
      );
    }
  }

  String _getFriendlyErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    } else if (errorStr.contains('missing-password')) {
      return 'Please enter your password.';
    } else if (errorStr.contains('email-already-in-use')) {
      return 'This email is already registered.';
    } else if (errorStr.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (errorStr.contains('weak-password')) {
      return 'Your password is too weak. Try using at least 6 characters.';
    } else if (errorStr.contains('network-request-failed')) {
      return 'No internet connection. Please check your connection and try again.';
    } else if (errorStr.contains('sign_in_failed') ||
        errorStr.contains('ApiException')) {
      return 'Google sign-in failed. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 300,
            color: const Color(0xFF54AF75),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: SvgPicture.asset(
                  'assets/redine.svg',
                  height: 30,
                  width: 30,
                ),
              ),
            ),
          ),
          Container(
            transform: Matrix4.translationValues(0, 150, 0),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: -20,
                      offset: Offset(0, -20),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLogin ? 'Welcome back' : 'Register',
                      style: GoogleFonts.livvic(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _isLogin
                          ? 'Login to your account'
                          : 'Create your new account',
                      style: GoogleFonts.livvic(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF54AF75),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!_isLogin) ...[
                      TextField(
                        controller: _usernameController,
                        decoration: _inputDecoration('Username'),
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: _emailController,
                      decoration: _inputDecoration('Email'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration('Password'),
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: _inputDecoration('Confirm Password'),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                          label: _isLogin ? 'Login' : 'Register',
                          onPressed: _submit,
                        ),
                    Row(
                      children: [
                        Text(
                          _isLogin
                              ? 'Don’t have an account?'
                              : 'Already have an account?',
                        ),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(_isLogin ? 'Register Now' : 'Log in'),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'or',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loginWithGoogle,
                        icon: Iconify(Logos.google_icon, size: 20),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
