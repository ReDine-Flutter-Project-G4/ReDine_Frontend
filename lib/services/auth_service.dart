import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redine_frontend/services/cache_service.dart';
import 'package:redine_frontend/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  getProfileImage({double size = 100}) {
    final photoUrl = _auth.currentUser?.photoURL;
    return Image.network(
      photoUrl ??
          "https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png",
      height: size,
      width: size,
      fit: BoxFit.cover,
    );
  }

  getUserName() {
    return _auth.currentUser?.displayName ?? "Guest";
  }

  getUserEmail() {
    return _auth.currentUser?.email ?? "guest@example.com";
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // User cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      final isFirstTime = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isFirstTime) {
        await FirestoreService.createUser(
          user: user,
          username: user.displayName ?? 'Guest',
        );
      }
      await FirestoreService.getUserPref(user.uid);
    }
  }

  Future<void> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      await FirestoreService.getUserPref(user.uid);
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
        "https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png",
      );
      await FirestoreService.createUser(
        user: user,
        username: username,
      ); // Save user data to Firestore
      await FirestoreService.getUserPref(user.uid);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await CacheService.clearUserPref();
  }
}
