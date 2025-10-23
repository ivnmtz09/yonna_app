import 'package:flutter/material.dart';
import '../widgets/app_styles.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  final ApiService _apiService = ApiService();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _apiService.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (data.containsKey('access')) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = data['detail'] ?? 'Credenciales incorrectas.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Revisa tu IP o el servidor.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/yonna.png', height: 100),
                  const SizedBox(height: 16),
                  const Text("Yonna App",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentOrange)),
                  const Text("by Yonna Akademia",
                      style: TextStyle(
                          fontSize: 14, color: AppColors.primaryGreen)),
                  const SizedBox(height: 24),
                  const Text("Iniciar Sesión", style: AppStyles.mainTitleStyle),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: _buildInputDecoration(
                        labelText: "Correo electrónico",
                        icon: Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.isEmpty || !v.contains('@'))
                            ? "Ingrese un correo válido"
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: _buildInputDecoration(
                            labelText: "Contraseña", icon: Icons.lock_outline)
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.primaryGreen),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? "Ingrese su contraseña"
                        : null,
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.accentOrange)
                      : _buildAuthButton(
                          context: context,
                          label: "Entrar",
                          onPressed: _login,
                          isPrimary: true),
                  const SizedBox(height: 16),
                  _buildAuthButton(
                      context: context,
                      label: "Entrar con Google",
                      onPressed: () {},
                      isPrimary: false,
                      icon: Icons.login),
                  const SizedBox(height: 8),
                  Text("Acceso con Google estará disponible próximamente.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()));
                    },
                    child: RichText(
                      text: TextSpan(
                          style: AppStyles.drawerItemStyle
                              .copyWith(color: AppColors.darkText),
                          children: const [
                            TextSpan(text: "¿No tienes cuenta? "),
                            TextSpan(
                                text: "Regístrate aquí",
                                style: TextStyle(
                                    color: AppColors.accentOrange,
                                    fontWeight: FontWeight.bold))
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      {required String labelText, required IconData icon}) {
    return InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.primaryGreen),
        prefixIcon: Icon(icon, color: AppColors.primaryGreen),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
            borderRadius: AppStyles.standardBorderRadius,
            borderSide:
                BorderSide(color: AppColors.primaryGreen.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(
            borderRadius: AppStyles.standardBorderRadius,
            borderSide:
                const BorderSide(color: AppColors.accentOrange, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: AppStyles.standardBorderRadius,
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppStyles.standardBorderRadius,
            borderSide: const BorderSide(color: Colors.red, width: 2)));
  }

  Widget _buildAuthButton(
      {required BuildContext context,
      required String label,
      required VoidCallback onPressed,
      required bool isPrimary,
      IconData? icon}) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.standardBorderRadius),
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: isPrimary
                    ? AppColors.accentOrange
                    : AppColors.backgroundWhite,
                foregroundColor: isPrimary
                    ? AppColors.backgroundWhite
                    : AppColors.primaryGreen,
                side: isPrimary
                    ? BorderSide.none
                    : const BorderSide(
                        color: AppColors.primaryGreen, width: 1.5),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            child: icon != null
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(icon),
                    const SizedBox(width: 10),
                    Text(label)
                  ])
                : Text(label)));
  }
}
