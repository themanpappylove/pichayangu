import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  void _register() async {
    setState(() => _loading = true);
    final api = ApiService();
    final success = await api.register(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _loading = false);
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome to Picha Yangu!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 8),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Register')),
          ],
        ),
      ),
    );
  }
}
