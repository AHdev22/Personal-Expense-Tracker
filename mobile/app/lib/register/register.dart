import 'package:app/Home/home.dart';
import 'package:app/login/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = "";

  void onSignUPPressed() async {
    setState(() => errorMessage = ""); // Reset previous errors

    // 1️⃣ Input validation
    if (nameController.text.isEmpty) {
      setState(() => errorMessage = "Name cannot be empty");
      return;
    }
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

    final url = Uri.parse("http://192.168.56.1:5291/api/auth/register");

    try {
      // 3️⃣ Send POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      // 4️⃣ Handle response
      if (response.statusCode == 200) {
        final token = data['token'];
        if (token != null) {
          debugPrint("Register successful: $token");

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
        // Use backend message if available
        setState(
          () => errorMessage =
              data['message'] ?? "Please check your details and try again",
        );
      } else {
        setState(() => errorMessage = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      // 5️⃣ Handle network error
      setState(() => errorMessage = "Network error: $e");
    } finally {
      // 6️⃣ Stop loading spinner
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
                      "Create your account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(nameController, 'Name'),
                    const SizedBox(height: 15),
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
                    _buildSignUpButton(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text("Sign in here"),
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

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSignUPPressed,
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
                "Sign up",
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
