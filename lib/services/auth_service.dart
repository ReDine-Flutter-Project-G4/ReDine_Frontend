import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redine_frontend/services/cache_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = userCredential.user;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = doc.data();
      if (userData != null) {
        userData.remove('createdAt');
        await UserPrefService.saveUserPref(userData); // Cache it
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
      // Update Firebase Auth profile
      await user.updateDisplayName(username);
      await user.updatePhotoURL(
        "https://www.thaimediafund.or.th/wp-content/uploads/2024/04/blank-profile-picture-973460_1280.png",
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'username': username,
        'avoidances': [],
        'favorites': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await UserPrefService.clearUserPref();
  }
}
