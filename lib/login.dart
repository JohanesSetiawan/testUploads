import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  var user = 4;
  var pass = 4;
  var baseURL = 'http://103.157.116.221:8088/elang-dashboard-backend/public';

  // Method untuk login
  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Username dan Password harus diisi');
      return;
    }

    if (_usernameController.text.length < user) {
      _showErrorDialog('Username harus memiliki minimal $user karakter');
      return;
    }

    if (_passwordController.text.length < pass) {
      _showErrorDialog('Password harus memiliki minimal $pass karakter');
      return;
    }

    final url = Uri.parse('$baseURL/api/v1/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['meta']['success']) {
          final token = data['token'];
          final username = data['data']['username'];
          final territory = data['data']['territory'];
          final role = data['data']['role'];
          final brand = data['data']['brand'];

          // Save user data
          await Provider.of<AuthProvider>(context, listen: false)
              .setUserData(token, username, territory, role, 0, brand);

          if (role == 1) {
            await Provider.of<AuthProvider>(context, listen: false)
                .fetchLockedDropdown();
          }

          if (role == 5) {
            await Provider.of<AuthProvider>(context, listen: false)
                .fetchLockedDropdown();
          }

          // Navigate to Homepage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Homepage(),
            ),
          );
        } else {
          _showErrorDialog(data['meta']['error']);
        }
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = '';

        if (data['meta']['error']['username'] != null) {
          errorMessage += data['meta']['error']['username'].join(', ') + '\n';
        }

        if (data['meta']['error']['password'] != null) {
          errorMessage += data['meta']['error']['password'].join(', ') + '\n';
        }
        _showErrorDialog(errorMessage.trim());
      } else {
        final data = jsonDecode(response.body);
        _showErrorDialog(data['meta']['message']);
      }
    } catch (e) {
      _showErrorDialog('Ada Kesalahan. Silahkan coba lagi.');
    }
  }

  // Menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Gagal'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/LOGO.png'),
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword; // Toggle visibility
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _login(); // Panggil API login jika form valid
                    }
                  },
                  child: const Text('Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
