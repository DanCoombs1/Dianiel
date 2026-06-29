import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppAuthUser {
  final String uid;
  final String? displayName;
  const AppAuthUser({required this.uid, this.displayName});
}

abstract class AuthRepository {
  Stream<AppAuthUser?> authStateChanges();
  Future<void> signInWithApple();
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);
  final FirebaseAuth _auth;

  @override
  Stream<AppAuthUser?> authStateChanges() => _auth.authStateChanges().map(
        (u) => u == null ? null : AppAuthUser(uid: u.uid, displayName: u.displayName),
      );

  @override
  Future<void> signInWithApple() async {
    final apple = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ]);
    final cred = OAuthProvider('apple.com').credential(
      idToken: apple.identityToken,
      accessToken: apple.authorizationCode,
    );
    final result = await _auth.signInWithCredential(cred);
    final name = [apple.givenName, apple.familyName].whereType<String>().join(' ').trim();
    if (name.isNotEmpty && result.user?.displayName == null) {
      await result.user?.updateDisplayName(name);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
