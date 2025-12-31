import 'package:app/Home/home.dart';
import 'package:app/register/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController(); 

  bool isLoading = false;
  String errorMessage = "";

  void onLoginPressed() async {
    setState(() => errorMessage = ""); // Reset previous errors

    // 1️⃣ Input validation
    if (emailController.text.isEmpty) {
      setState(() => errorMessage = "Email cannot be empty");
      return;
    }
    if (!RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    ).hasMatch(emailController.text)) {
      setState(() => errorMessage = "Enter a valid email");
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() => errorMessage = "Password cannot be empty");
      return;
    }
    if (passwordController.text.length < 8) {
      setState(() => errorMessage = "Password must be at least 8 characters");
      return;
    }

    // 2️⃣ Show loading spinner
    setState(() => isLoading = true);

    final url = Uri.parse("http://192.168.56.1:5291/api/auth/login");

    try {
      // 3️⃣ Send POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      // 4️⃣ Handle response
      if (response.statusCode == 200) {
        final token = data['token'];
        if (token != null) {
          debugPrint("Login successful: $token");

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(token: token), // بعت token هنا
            ),
          );
        } else {
          setState(() => errorMessage = "Invalid server response");
        }
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        setState(
          () => errorMessage = data['message'] ?? "Invalid email or password",
        );
      } else {
        setState(() => errorMessage = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => errorMessage = "Network error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sign in to your account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(emailController, 'Email address'),
                    const SizedBox(height: 15),
                    _buildTextField(
                      passwordController,
                      'Password',
                      obscure: true,
                    ),
                    const SizedBox(height: 10),
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text("Forgot Password?"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSignInButton(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Not a member?",
                          style: TextStyle(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text("Create a new account"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 3),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onLoginPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Sign in",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
