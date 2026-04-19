import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);

    final userModel = UserModel(
      id: user.uid,
      name: name,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(user.uid).set(userModel.toMap());

    if (role == 'provider') {
      await _db.collection('providers').doc(user.uid).set({
        'user_id': user.uid,
        'name': name,
        'email': email,
        'service_type': '',
        'description': '',
        'price': 0,
        'rating': 0.0,
        'review_count': 0,
        'location': {'lat': 0, 'lng': 0},
        'isAvailable': true,
        'tags': [],
      });
    }

    return userModel;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return await getUserData(credential.user!.uid);
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
