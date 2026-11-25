// lib/core/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _checkLoginStatus();
  }

  final UserService _userService = UserService();

  bool _initialized = false;
  bool _isLoggedIn = false;
  bool _isOfflineSession = false;
  String? _username;
  String? _email;
  String? _uid;
  User? _firebaseUser;

  bool get initialized => _initialized;
  bool get isLoggedIn => _isLoggedIn;
  bool get isOfflineSession => _isOfflineSession;
  String? get username => _username;
  String? get email => _email;
  String? get uid => _uid;
  User? get firebaseUser => _firebaseUser;

  Future<void> _checkLoginStatus() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _setUserFromFirebase(currentUser);
        _initialized = true;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('FirebaseAuth checkLoginStatus error: $e');
    }

    // Fallback offline: verifica se já havia sessão salva localmente no dispositivo
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _uid = prefs.getString('uid');
      _username = prefs.getString('username');
      _email = prefs.getString('email');
      if (_isLoggedIn) {
        _isOfflineSession = true;
      }
    } catch (e) {
      debugPrint('SharedPreferences checkLoginStatus error: $e');
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> _setUserFromFirebase(User user) async {
    _firebaseUser = user;
    _uid = user.uid;
    _email = user.email;
    _isOfflineSession = false;

    // Tenta pegar displayName do Firestore (se falhar ou offline, usa fallback)
    final profile = await _userService.getProfile(user.uid);
    _username = profile?['displayName'] as String? ??
        user.displayName ??
        user.email?.split('@').first ??
        'Usuário';

    _isLoggedIn = true;

    // Persiste no cache local para suportar futuras aberturas offline
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('uid', _uid ?? '');
      await prefs.setString('username', _username ?? '');
      await prefs.setString('email', _email ?? '');
    } catch (_) {}
  }

  /// Retorna null em caso de sucesso ou a mensagem de erro em caso de falha.
  Future<String?> login(String emailInput, String password, {bool forceCreate = false}) async {
    if (emailInput.isEmpty || password.isEmpty) return 'Preencha e-mail e senha.';

    final prefs = await SharedPreferences.getInstance();
    final cachedEmail = prefs.getString('email');
    final cachedUid = prefs.getString('uid');

    try {
      UserCredential credential;
      if (forceCreate) {
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailInput,
          password: password,
        );
      } else {
        try {
          credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailInput,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' ||
              e.code == 'invalid-credential' ||
              e.code == 'channel-error') {
            credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailInput,
              password: password,
            );
          } else {
            rethrow;
          }
        }
      }

      await _setUserFromFirebase(credential.user!);
      await _userService.upsertProfile(
        uid: _uid!,
        email: _email!,
        displayName: _username,
      );

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('uid', _uid!);
      await prefs.setString('username', _username ?? '');
      await prefs.setString('email', _email ?? '');

      notifyListeners();
      return null; // sucesso online
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthProvider.login FirebaseAuthException: code=${e.code} msg=${e.message}');
      if (e.code == 'network-request-failed') {
        // Sem conexão: se já existia sessão prévia desse e-mail no aparelho, autoriza login offline!
        if (cachedEmail != null &&
            cachedEmail.trim().toLowerCase() == emailInput.trim().toLowerCase() &&
            cachedUid != null &&
            cachedUid.isNotEmpty) {
          _uid = cachedUid;
          _email = cachedEmail;
          _username = prefs.getString('username') ?? cachedEmail.split('@').first;
          _isLoggedIn = true;
          _isOfflineSession = true;
          await prefs.setBool('isLoggedIn', true);
          notifyListeners();
          return null; // Sucesso no login offline com credenciais salvas!
        }
        return 'Sem conexão com internet. Você pode entrar no Modo Offline clicando no botão abaixo.';
      }
      return _friendlyError(e.code);
    } catch (e) {
      debugPrint('AuthProvider.login error: $e');
      return 'Erro inesperado: $e';
    }
  }

  /// Permite entrar diretamente no modo offline sem internet
  Future<void> loginOffline() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedEmail = prefs.getString('email');
    final cachedUid = prefs.getString('uid');

    if (cachedUid != null && cachedUid.isNotEmpty) {
      _uid = cachedUid;
      _email = cachedEmail ?? 'offline@agendify.local';
      _username = prefs.getString('username') ?? 'Usuário Offline';
    } else {
      _uid = 'local_user';
      _email = 'offline@agendify.local';
      _username = 'Usuário Local';
      await prefs.setString('uid', _uid!);
      await prefs.setString('username', _username!);
      await prefs.setString('email', _email!);
    }

    _isLoggedIn = true;
    _isOfflineSession = true;
    await prefs.setBool('isLoggedIn', true);
    notifyListeners();
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Este e-mail já está cadastrado. Tente entrar.';
      case 'user-not-found':       return 'Usuário não encontrado.';
      case 'wrong-password':       return 'Senha incorreta.';
      case 'invalid-email':        return 'E-mail inválido.';
      case 'weak-password':        return 'Senha fraca — use pelo menos 6 caracteres.';
      case 'operation-not-allowed': return 'Login por e-mail não está ativado no Firebase. Ative em Authentication → Método de login.';
      case 'too-many-requests':    return 'Muitas tentativas. Aguarde alguns minutos.';
      case 'network-request-failed': return 'Sem conexão com internet.';
      default: return 'Erro de autenticação ($code).';
    }
  }

  Future<void> updateDisplayName(String newName) async {
    await _userService.updateDisplayName(newName);
    _username = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newName);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('AuthProvider.logout error: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('uid');

    _isLoggedIn = false;
    _isOfflineSession = false;
    _username = null;
    _email = null;
    _uid = null;
    _firebaseUser = null;
    notifyListeners();
  }
}
