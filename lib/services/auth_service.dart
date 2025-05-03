import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redine_frontend/services/cache_service.dart';
import 'package:redine_frontend/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      final userData = await FirestoreService.getUserData(user.uid);
      if (userData != null) {
        userData.remove('createdAt');
        await CacheService.saveUserPref(userData); // Cache it
      }
    }
  }

  Future<void> register(String email, String password, String username) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(username);
      await user.updatePhotoURL(
        "https://www.thaimediafund.or.th/wp-content/uploads/2024/04/blank-profile-picture-973460_1280.png",
      );
      await FirestoreService.createUser(
        user: user,
        username: username,
      ); // Save user data to Firestore
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await CacheService.clearUserPref();
  }
}
