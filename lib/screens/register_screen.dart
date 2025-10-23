import 'package:flutter/material.dart';
import '../widgets/app_styles.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

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
  String _errorMessage = '';

  final ApiService _apiService = ApiService();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _apiService.register(
        email: _emailCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        password1: _password1Ctrl.text,
        password2: _password2Ctrl.text,
      );

      if (data.containsKey('email')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Registro exitoso! Ya puedes iniciar sesión."),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        setState(() {
          if (data.values.isNotEmpty && data.values.first is List) {
            _errorMessage = data.values.first[0];
          } else {
            _errorMessage = data.toString();
          }
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: AppColors.primaryGreen,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/yonna.png', height: 80),
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
                  const Text("Crear Cuenta", style: AppStyles.mainTitleStyle),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _firstNameCtrl,
                    decoration: _buildInputDecoration(
                        labelText: "Nombre", icon: Icons.person_outline),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Ingresa tu nombre" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameCtrl,
                    decoration: _buildInputDecoration(
                        labelText: "Apellido", icon: Icons.person_outline),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Ingresa tu apellido" : null,
                  ),
                  const SizedBox(height: 16),
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
                    controller: _password1Ctrl,
                    obscureText: _obscurePassword1,
                    decoration: _buildInputDecoration(
                            labelText: "Contraseña", icon: Icons.lock_outline)
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword1
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.primaryGreen),
                        onPressed: () {
                          setState(
                              () => _obscurePassword1 = !_obscurePassword1);
                        },
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 8)
                        ? "Mínimo 8 caracteres"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password2Ctrl,
                    obscureText: _obscurePassword2,
                    decoration: _buildInputDecoration(
                            labelText: "Confirmar contraseña",
                            icon: Icons.lock_outline)
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword2
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.primaryGreen),
                        onPressed: () {
                          setState(
                              () => _obscurePassword2 = !_obscurePassword2);
                        },
                      ),
                    ),
                    validator: (v) => (v != _password1Ctrl.text)
                        ? "Las contraseñas no coinciden"
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
                          label: "Registrarse",
                          onPressed: _register,
                          isPrimary: true),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    },
                    child: RichText(
                      text: TextSpan(
                          style: AppStyles.drawerItemStyle
                              .copyWith(color: AppColors.darkText),
                          children: const [
                            TextSpan(text: "¿Ya tienes cuenta? "),
                            TextSpan(
                                text: "Inicia Sesión",
                                style: TextStyle(
                                    color: AppColors.accentOrange,
                                    fontWeight: FontWeight.bold))
                          ]),
                    ),
                  ),
                  const SizedBox(height: 20),
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
      required bool isPrimary}) {
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
            child: Text(label)));
  }
}
