import 'package:flutter/material.dart';
import 'package:redine_frontend/widgets/custom_button.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background box
          Container(height: 300, color: const Color(0xFF54AF75)),

          // Foreground form container
          Container(
            transform: Matrix4.translationValues(0.0, 150.0, 0.0),
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                // padding: const EdgeInsets.only(top: 70),
                decoration: const BoxDecoration(
                  color: Color(0xFFEDEDED),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
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
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        'Login to your account',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
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
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ), // grey border
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF54AF75),
                                  width: 2,
                                ), // green border when focus
                                borderRadius: BorderRadius.circular(8),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ), // grey label
                              floatingLabelStyle: TextStyle(
                                color: Color(
                                  0xFF54AF75,
                                ), // green label when focused
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ), // grey border
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF54AF75),
                                  width: 2,
                                ), // green border when focus
                                borderRadius: BorderRadius.circular(8),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ), // grey label
                              floatingLabelStyle: TextStyle(
                                color: Color(
                                  0xFF54AF75,
                                ), // green label when focused
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: 'Login',
                            onPressed: () async {
                              try {
                                await _authService.signIn(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Login failed: $e')),
                                );
                              }
                            },
                          ),
                          Row(
                            children: [
                              Text('Don’t have an account?'),
                              TextButton(
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      '/register',
                                    ),
                                child: const Text('Register Now'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 300),
                        ],
                      ),
                    ),
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
