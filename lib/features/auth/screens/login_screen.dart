// lib/features/auth/screens/login_screen.dart
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
  bool _isCreatingAccount = false;

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

  Future<void> _loadInitialData() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    await taskProvider.loadTasks();
    await eventProvider.loadEvents();
    await categoryProvider.loadCategories();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    final error = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      forceCreate: _isCreatingAccount,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      if (authProvider.isOfflineSession) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Conectado em Modo Offline com sucesso!'),
            backgroundColor: Colors.teal,
            duration: Duration(seconds: 4),
          ),
        );
      }
      await _loadInitialData();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
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

  Future<void> _enterOfflineMode() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loginOffline();
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Modo Offline ativado. Seus dados serão sincronizados ao conectar.'),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 4),
      ),
    );
    await _loadInitialData();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
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
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.calendar_month,
                          size: 80,
                          color: Color(0xFF185286),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Título
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

                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OU SEM INTERNET',
                            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Botão Modo Offline
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _enterOfflineMode,
                        icon: const Icon(Icons.cloud_off),
                        label: const Text('Acessar agenda offline'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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
