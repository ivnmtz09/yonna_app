import 'package:flutter/material.dart';
import 'package:yonna_app/services/auth_service.dart';
import 'package:yonna_app/screens/home_screen.dart';
import 'package:yonna_app/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AuthService.login(_emailCtrl.text, _passwordCtrl.text);

    setState(() => _isLoading = false);

    if (res["ok"]) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      setState(
        () => _errorMessage = "Credenciales incorrectas o error de conexión",
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AuthService.loginWithGoogle();

    setState(() => _isLoading = false);

    if (res["ok"]) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      setState(() => _errorMessage = "Error con Google Sign-In");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 230),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/yonna.png', height: 100),
                const SizedBox(height: 24),
                const Text(
                  "Iniciar sesión",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8025),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Ingrese su correo electrónico" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Ingrese su contraseña" : null,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 8),
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFFFF8025))
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8025),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          "Entrar",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loginWithGoogle,
                  icon: const Icon(Icons.login, color: Color(0xFFFF8025)),
                  label: const Text(
                    "Entrar con Google",
                    style: TextStyle(color: Color(0xFFFF8025)),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: Color(0xFFFF8025)),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "¿No tienes cuenta? Regístrate aquí",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
