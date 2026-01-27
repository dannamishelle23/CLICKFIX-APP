import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_colors.dart';
import 'auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_input.dart';
import 'widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  final String? confirmationMessage;

  const LoginScreen({super.key, this.confirmationMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.confirmationMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.confirmationMessage!),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _loading = true);

      await _authService.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
    } on AuthException catch (e) {
      _showError(_mapAuthError(e.message));
    } catch (_) {
      _showError('Error al iniciar sesion');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Correo o contrasena incorrectos';
    }
    if (message.contains('Email not confirmed')) {
      return 'Debes confirmar tu correo electronico';
    }
    return message;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: '',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Text(
                  'LOGO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Servicios tecnicos a tu alcance',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 32),
            AuthInput(
              controller: _emailCtrl,
              label: 'Correo electronico',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su correo';
                }
                if (!value.contains('@')) {
                  return 'Correo no valido';
                }
                return null;
              },
            ),
            AuthInput(
              controller: _passwordCtrl,
              label: 'Contrasena',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su contrasena';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Olvide mi contrasena',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AuthButton(
              text: 'Ingresar',
              loading: _loading,
              onPressed: _login,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No tienes cuenta?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Crear una ahora',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
