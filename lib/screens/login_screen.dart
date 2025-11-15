import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final success = await provider.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Credenciales incorrectas'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppStyles.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/yonna.png', height: 120),
                  const SizedBox(height: AppStyles.spacingM),
                  Text(
                    'Yonna Akademia',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aprende Wayuunaiki',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingXL),
                  Text('Iniciar Sesión', style: AppTextStyles.h3),
                  const SizedBox(height: AppStyles.spacingL),
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
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: AppStyles.inputDecoration(
                      labelText: 'Contraseña',
                      icon: Icons.lock_outline,
                      hintText: '••••••••',
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primaryOrange,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Ingrese su contraseña'
                        : null,
                  ),
                  const SizedBox(height: AppStyles.spacingXL),
                  Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: provider.isLoading ? null : _login,
                              style: AppStyles.primaryButton,
                              child: provider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppColors.whiteText,
                                        ),
                                      ),
                                    )
                                  : const Text('Entrar'),
                            ),
                          ),
                          const SizedBox(height: AppStyles.spacingM),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.login),
                              label: const Text('Entrar con Google'),
                              onPressed: () {
                                // TODO: Implementar Google Sign-In
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Google Sign-In próximamente'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: AppStyles.outlinedButton,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppStyles.spacingS),
                  Text(
                    'Acceso con Google estará disponible próximamente',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppStyles.spacingL),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkText,
                        ),
                        children: [
                          const TextSpan(text: '¿No tienes cuenta? '),
                          TextSpan(
                            text: 'Regístrate aquí',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
