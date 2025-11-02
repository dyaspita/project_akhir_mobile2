import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';
import '../services/hash.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});
  final String title;

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      final userBox = Hive.box<User>('userbox');
      final storedUser = userBox.values.firstWhere(
        (u) => u.username == username,
        orElse: () => User(username: '', password: '', role: ''),
      );

      if (storedUser.username.isNotEmpty &&
          storedUser.password == hashPassword(password)) {
        setState(() => _errorMessage = null);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUsername', username);
        await prefs.setString('role', storedUser.role);

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Username atau password salah.';
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacementNamed('/register');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 68, 119, 248);
    const darkTextColor = Colors.black87;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [BoxShadow(color: primaryColor, blurRadius: 10)],
            ),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Login",
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor)),
                    const SizedBox(height: 10),
                    const Text('Masukkan username dan password Anda.',
                        style: TextStyle(color: darkTextColor)),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: primaryColor),
                        labelText: 'Username',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Username harus diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: primaryColor),
                        labelText: 'Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: primaryColor,
                          ),
                          onPressed: () =>
                              setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.length < 6 ? 'Password minimal 6 karakter' : null,
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Login',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum punya akun?"),
                        TextButton(
                          onPressed: _navigateToRegister,
                          child: const Text(
                            'Daftar sekarang',
                            style: TextStyle(
                                color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
