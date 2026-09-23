import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/providers/event_provider.dart';
import '../../../core/providers/category_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isCreatingAccount = false; // true = modo cadastro, false = modo login

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe seu e-mail.';
    if (!value.contains('@') || !value.contains('.')) return 'E-mail inválido.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe sua senha.';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final error = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      forceCreate: _isCreatingAccount,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      // sucesso
      await taskProvider.loadTasks();
      await eventProvider.loadEvents();
      await categoryProvider.loadCategories();
      navigator.pushReplacementNamed(AppRoutes.home);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/images/agendify_logo.png',
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Título muda conforme o modo
                    Text(
                      _isCreatingAccount ? 'Criar nova conta' : 'Entre na sua conta',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // E-mail
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: _validatePassword,
                      decoration: const InputDecoration(
                        labelText: 'Senha (mínimo 6 caracteres)',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão principal
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(_isCreatingAccount ? Icons.person_add : Icons.login),
                        label: Text(
                          _isLoading
                              ? (_isCreatingAccount ? 'Criando conta...' : 'Entrando...')
                              : (_isCreatingAccount ? 'Criar conta' : 'Entrar'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Alterna entre login e cadastro
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                                _isCreatingAccount = !_isCreatingAccount;
                                _formKey.currentState?.reset();
                              }),
                      child: Text(
                        _isCreatingAccount
                            ? 'Já tenho uma conta — Entrar'
                            : 'Não tenho conta — Criar conta',
                      ),
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
