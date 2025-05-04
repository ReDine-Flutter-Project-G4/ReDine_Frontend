import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:redine_frontend/services/cache_service.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> createUser({
    required User user,
    required String username,
  }) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'username': username,
      'avoids': [],
      'allergens': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> getUserPref(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final userPref = doc.data();
    if (userPref != null) {
      userPref.remove('createdAt');
      await CacheService.saveUserPref(userPref); // Cache it
    }
    return userPref;
  }

  static Future<void> updatePreferences(
    String uid,
    List<String> avoids,
    List<String> allergens,
  ) async {
    await _firestore.collection('users').doc(uid).update({
      'avoids': avoids,
      'allergens': allergens,
    });
  }
}
