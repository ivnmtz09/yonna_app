import 'package:flutter/material.dart';
import 'package:yonna_app/services/auth_service.dart';
import 'package:yonna_app/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _password1Ctrl = TextEditingController();
  final _password2Ctrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AuthService.register({
      "email": _emailCtrl.text.trim(),
      "first_name": _firstNameCtrl.text.trim(),
      "last_name": _lastNameCtrl.text.trim(),
      "password1": _password1Ctrl.text,
      "password2": _password2Ctrl.text,
    });

    setState(() => _isLoading = false);

    if (res["ok"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registro exitoso, ahora puedes iniciar sesión"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      setState(() => _errorMessage = res["error"].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/yonna.png', height: 100),
                const SizedBox(height: 24),
                const Text(
                  "Crear cuenta",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8025),
                  ),
                ),
                const SizedBox(height: 24),

                // Nombre
                TextFormField(
                  controller: _firstNameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.isEmpty ? "Ingrese su nombre" : null,
                ),
                const SizedBox(height: 16),

                // Apellido
                TextFormField(
                  controller: _lastNameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Apellido",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.isEmpty ? "Ingrese su apellido" : null,
                ),
                const SizedBox(height: 16),

                // Correo
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Ingrese un correo";
                    if (!v.contains("@")) return "Correo inválido";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contraseña 1
                TextFormField(
                  controller: _password1Ctrl,
                  obscureText: _obscurePassword1,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword1
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword1 = !_obscurePassword1);
                      },
                    ),
                  ),
                  validator: (v) =>
                      v!.length < 6 ? "Mínimo 6 caracteres" : null,
                ),
                const SizedBox(height: 16),

                // Contraseña 2
                TextFormField(
                  controller: _password2Ctrl,
                  obscureText: _obscurePassword2,
                  decoration: InputDecoration(
                    labelText: "Confirmar contraseña",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword2
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword2 = !_obscurePassword2);
                      },
                    ),
                  ),
                  validator: (v) => v != _password1Ctrl.text
                      ? "Las contraseñas no coinciden"
                      : null,
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
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8025),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          "Registrarse",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "¿Ya tienes cuenta? ",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "Inicia sesión",
                          style: TextStyle(
                            color: Color(0xFFFF8025),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
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
