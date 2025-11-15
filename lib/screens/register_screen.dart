import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';

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
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _password1Ctrl.dispose();
    _password2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final success = await provider.register(
      email: _emailCtrl.text.trim(),
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      password1: _password1Ctrl.text,
      password2: _password2Ctrl.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Ya puedes iniciar sesión'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al registrarse'),
          backgroundColor: AppColors.errorRed,
        ),
      );
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
          color: AppColors.primaryBlue,
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppStyles.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/yonna.png', height: 100),
                  const SizedBox(height: AppStyles.spacingM),
                  Text(
                    'Yonna Akademia',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingXL),
                  Text('Crear Cuenta', style: AppTextStyles.h3),
                  const SizedBox(height: AppStyles.spacingL),
                  TextFormField(
                    controller: _firstNameCtrl,
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Nombre',
                      icon: Icons.person_outline,
                      hintText: 'Tu nombre',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Ingresa tu nombre' : null,
                  ),
                  const SizedBox(height: AppStyles.spacingM),
                  TextFormField(
                    controller: _lastNameCtrl,
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Apellido',
                      icon: Icons.person_outline,
                      hintText: 'Tu apellido',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Ingresa tu apellido' : null,
                  ),
                  const SizedBox(height: AppStyles.spacingM),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      hintText: 'tu@correo.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.isEmpty || !v.contains('@'))
                            ? 'Ingrese un correo válido'
                            : null,
                  ),
                  const SizedBox(height: AppStyles.spacingM),
                  TextFormField(
                    controller: _password1Ctrl,
                    obscureText: _obscurePassword1,
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Contraseña',
                      icon: Icons.lock_outline,
                      hintText: 'Mínimo 8 caracteres',
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword1
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primaryOrange,
                        ),
                        onPressed: () {
                          setState(
                              () => _obscurePassword1 = !_obscurePassword1);
                        },
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 8)
                        ? 'Mínimo 8 caracteres'
                        : null,
                  ),
                  const SizedBox(height: AppStyles.spacingM),
                  TextFormField(
                    controller: _password2Ctrl,
                    obscureText: _obscurePassword2,
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Confirmar contraseña',
                      icon: Icons.lock_outline,
                      hintText: 'Repite tu contraseña',
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword2
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primaryOrange,
                        ),
                        onPressed: () {
                          setState(
                              () => _obscurePassword2 = !_obscurePassword2);
                        },
                      ),
                    ),
                    validator: (v) => (v != _password1Ctrl.text)
                        ? 'Las contraseñas no coinciden'
                        : null,
                  ),
                  const SizedBox(height: AppStyles.spacingXL),
                  Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _register,
                          style: AppStyles.primaryButton,
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.whiteText,
                                    ),
                                  ),
                                )
                              : const Text('Registrarse'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppStyles.spacingL),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkText,
                        ),
                        children: [
                          const TextSpan(text: '¿Ya tienes cuenta? '),
                          TextSpan(
                            text: 'Inicia Sesión',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
