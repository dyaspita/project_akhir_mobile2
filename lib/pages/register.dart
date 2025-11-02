import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/user.dart';
import '../services/hash.dart';
import '../services/session_manajer.dart';

class Register extends StatefulWidget {
  const Register({super.key, required this.title});
  final String title;

  @override
  State<Register> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _errorMessage;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      final userBox = Hive.box<User>('userbox');

      if (userBox.containsKey(username)) {
        setState(() => _errorMessage = 'Username "$username" sudah terdaftar.');
        return;
      }

      final newUser = User(
        username: username,
        password: hashPassword(password),
        role: 'user',
      );

      await userBox.put(username, newUser);

      await SessionManager.saveLogin(username, newUser.role);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Pendaftaran berhasil!')));
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
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
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Register",
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: darkTextColor),
                    ),
                    const SizedBox(height: 10),
                    const Text('Masukkan username dan password Anda', style: TextStyle(color: darkTextColor)),
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: primaryColor),
                        labelText: 'Username',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Username harus terisi' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: primaryColor),
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: primaryColor),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Password minimal 6 karakter'
                          : null,
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Daftar Sekarang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sudah punya akun?"),
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: const Text('Login disini',
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        )
                      ],
                    )
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
