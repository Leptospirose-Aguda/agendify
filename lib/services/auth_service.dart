class AuthService {
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // TODO: conectar com autenticação real.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return email.isNotEmpty && password.isNotEmpty;
  }

  Future<void> logout() async {
    // TODO: limpar token/sessão.
  }
}
