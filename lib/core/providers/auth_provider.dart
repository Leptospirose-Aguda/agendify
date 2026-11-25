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

    // Fallback offline: restaura sessão salva no SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSavedSession = prefs.getBool('isLoggedIn') ?? false;
      if (hasSavedSession) {
        _isLoggedIn = true;
        _uid = prefs.getString('uid') ?? 'local_user';
        _username = prefs.getString('username') ?? 'Usuário';
        _email = prefs.getString('email') ?? 'offline@agendify.local';
        _isOfflineSession = true;
        debugPrint('AuthProvider: sessão offline restaurada para $_email');
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

    final profile = await _userService.getProfile(user.uid);
    _username = profile?['displayName'] as String? ??
        user.displayName ??
        user.email?.split('@').first ??
        'Usuário';

    _isLoggedIn = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('uid', _uid ?? '');
      await prefs.setString('username', _username ?? '');
      await prefs.setString('email', _email ?? '');
    } catch (_) {}
  }

  /// Tenta login online. Se sem internet, autentica offline imediatamente.
  Future<String?> login(String emailInput, String password, {bool forceCreate = false}) async {
    if (emailInput.isEmpty || password.isEmpty) return 'Preencha e-mail e senha.';

    final prefs = await SharedPreferences.getInstance();
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
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthProvider.login FirebaseAuthException: code=${e.code} msg=${e.message}');
      if (e.code == 'network-request-failed') {
        // Sem internet: autentica no modo offline automaticamente com o e-mail informado!
        _uid = cachedUid ?? 'offline_${emailInput.hashCode}';
        _email = emailInput;
        _username = emailInput.split('@').first;
        _isLoggedIn = true;
        _isOfflineSession = true;
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('uid', _uid!);
        await prefs.setString('username', _username!);
        await prefs.setString('email', _email!);
        notifyListeners();
        return null; // Login offline concedido!
      }
      return _friendlyError(e.code);
    } catch (e) {
      debugPrint('AuthProvider.login error: $e');
      // Qualquer outro erro de rede não mapeado também permite login offline
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('failed host lookup')) {
        _uid = cachedUid ?? 'offline_${emailInput.hashCode}';
        _email = emailInput;
        _username = emailInput.split('@').first;
        _isLoggedIn = true;
        _isOfflineSession = true;
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('uid', _uid!);
        await prefs.setString('username', _username!);
        await prefs.setString('email', _email!);
        notifyListeners();
        return null;
      }
      return 'Erro inesperado: $e';
    }
  }

  /// Entrada direta em modo offline
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
      _username = 'Usuário Offline';
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
