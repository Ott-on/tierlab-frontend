import 'package:flutter/material.dart';
import '../core/services/supabase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLoginMode) {
        await SupabaseService().signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await SupabaseService().signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (context.mounted) {
        final message = error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha: $message')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Entrar' : 'Registrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Acesse sua conta Tierlab',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o e-mail';
                          }
                          if (!value.contains('@')) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a senha';
                          }
                          if (value.trim().length < 6) {
                            return 'Senha deve ter ao menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              _isLoading
                                  ? 'Aguarde...'
                                  : (_isLoginMode ? 'Entrar' : 'Registrar'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                          });
                        },
                  child: Text(
                    _isLoginMode
                        ? 'Não tem conta? Registre-se'
                        : 'Já tem conta? Faça login',
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
