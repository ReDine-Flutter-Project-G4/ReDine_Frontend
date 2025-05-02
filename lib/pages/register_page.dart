import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redine_frontend/widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

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

  Future<void> _register() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_passwordController.text != _confirmPasswordController.text) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.register(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Register failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            height: 300,
            color: const Color(0xFF54AF75),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: SvgPicture.asset('assets/redine.svg', height: 30, width: 30),
              ),
            ),
          ),
          // Foreground form
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
                      spreadRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Register', style: GoogleFonts.livvic(fontSize: 25, fontWeight: FontWeight.w700)),
                          Text(
                            'Create your new account',
                            style: GoogleFonts.livvic(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF54AF75)),
                          ),
                        ],
                      ),
                    ),
                    // Inputs
                    TextField(controller: _emailController, decoration: _inputDecoration('Email')),
                    const SizedBox(height: 10),
                    TextField(controller: _passwordController, obscureText: true, decoration: _inputDecoration('Password')),
                    const SizedBox(height: 10),
                    TextField(controller: _confirmPasswordController, obscureText: true, decoration: _inputDecoration('Confirm Password')),
                    const SizedBox(height: 20),
                    // Register button
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(label: 'Register', onPressed: _register),
                    const SizedBox(height: 10),
                    // Already have account
                    Row(
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('Log in'),
                        ),
                      ],
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
