abstract class IFirebaseAuthContract {
  Future<bool> signInWithGoogle();
  Future<bool> signOut();
  Future<bool> signInWithEmail(String email);
}
