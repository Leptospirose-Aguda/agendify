import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _checkLoginStatus();
  }

  final UserService _userService = UserService();

  bool _isLoggedIn = false;
  String? _username;
  String? _email;
  String? _uid;
  User? _firebaseUser;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get email => _email;
  String? get uid => _uid;
  User? get firebaseUser => _firebaseUser;

  Future<void> _checkLoginStatus() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _setUserFromFirebase(currentUser);
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('FirebaseAuth checkLoginStatus error: $e');
    }

    // Fallback: verifica sessão local
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _username = prefs.getString('username');
    _email = prefs.getString('email');
    notifyListeners();
  }

  Future<void> _setUserFromFirebase(User user) async {
    _firebaseUser = user;
    _uid = user.uid;
    _email = user.email;

    // Tenta pegar displayName do Firestore (pode ter sido atualizado)
    final profile = await _userService.getProfile(user.uid);
    _username = profile?['displayName'] as String? ??
        user.displayName ??
        user.email?.split('@').first ??
        'Usuário';

    _isLoggedIn = true;
  }

  /// Retorna null em caso de sucesso ou a mensagem de erro em caso de falha.
  Future<String?> login(String emailInput, String password, {bool forceCreate = false}) async {
    if (emailInput.isEmpty || password.isEmpty) return 'Preencha e-mail e senha.';

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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', _username ?? '');
      await prefs.setString('email', _email ?? '');

      notifyListeners();
      return null; // sucesso
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthProvider.login FirebaseAuthException: code=${e.code} msg=${e.message}');
      return _friendlyError(e.code);
    } catch (e) {
      debugPrint('AuthProvider.login error: $e');
      return 'Erro inesperado: $e';
    }
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

    _isLoggedIn = false;
    _username = null;
    _email = null;
    _uid = null;
    _firebaseUser = null;
    notifyListeners();
  }
}
