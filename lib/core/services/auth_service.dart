import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Servico centralizado para operacoes de autenticacao Firebase.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream de mudancas no estado do usuario autenticado.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario atualmente autenticado (pode ser null).
  User? get currentUser => _auth.currentUser;

  /// Cria uma nova conta com email e senha.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Faz login com email e senha.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Faz login com Google.
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'canceled',
        message: 'Login Google cancelado',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  /// Faz login com Apple.
  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    return await _auth.signInWithCredential(credential);
  }

  /// Envia email de redefinicao de senha.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Envia email de redefinicao de senha com suporte a deep link.
  ///
  /// Ao passar [continueUrl] + [handleCodeInApp], o link no email pode
  /// abrir diretamente na aplicação (universal link / app link) em vez
  /// de abrir o browser. Quando `handleCodeInApp` é `true`, o código
  /// não é consumido automaticamente e a app deve tratar a ação.
  Future<void> sendPasswordResetEmailWithLink(
    String email, {
    String? continueUrl,
    bool handleCodeInApp = false,
    String? linkDomain,
    String? androidPackageName,
    bool androidInstallApp = true,
    String? androidMinimumVersion,
    String? iOSBundleId,
  }) async {
    final settings = ActionCodeSettings(
      url: continueUrl ?? 'https://loahapp.firebaseapp.com',
      handleCodeInApp: handleCodeInApp,
      linkDomain: linkDomain,
      androidPackageName: androidPackageName,
      androidInstallApp: androidInstallApp,
      androidMinimumVersion: androidMinimumVersion,
      iOSBundleId: iOSBundleId,
    );
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
      actionCodeSettings: settings,
    );
  }

  /// Valida o código de ação (oobCode) de redefinição de senha.
  ///
  /// Retorna o email associado ao código. Lança [FirebaseAuthException]
  /// se o código for inválido, expirado, etc.
  Future<String> verifyPasswordResetCode(String oobCode) async {
    return await _auth.verifyPasswordResetCode(oobCode);
  }

  /// Confirma a redefinição de senha usando o código de ação.
  Future<void> resetPassword({
    required String oobCode,
    required String newPassword,
  }) async {
    await _auth.confirmPasswordReset(
      code: oobCode,
      newPassword: newPassword,
    );
  }

  /// Altera a senha do usuario atual, verificando a senha atual primeiro.
  /// Reautentica o usuario com [currentPassword] e, se bem-sucedido,
  /// atualiza para [newPassword].
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Nenhum usuario autenticado',
      );
    }

    final email = user.email;
    if (email == null) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'Conta sem email associado (login social)',
      );
    }

    // Reautenticar com a senha atual
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    // Atualizar para a nova senha
    await user.updatePassword(newPassword);
  }

  /// Envia email de verificacao para o usuario atual.
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Reautentica o utilizador com a senha atual (para contas email/senha).
  /// Útil antes de operações sensíveis como exclusão de conta.
  ///
  /// Lança [FirebaseAuthException] se a senha estiver errada ou se o
  /// utilizador não tiver email associado.
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Nenhum utilizador autenticado',
      );
    }
    final email = user.email;
    if (email == null) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'Conta sem email associado (login social)',
      );
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  /// Apaga a conta do Firebase Auth permanentemente.
  /// Os dados do utilizador (Firestore, Storage) devem ser apagados
  /// ANTES de chamar este método, via [UserService.deleteUserContent].
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Nenhum utilizador autenticado',
      );
    }
    await user.delete();
  }

  /// Faz logout.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

