import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance.collection('users');

  Stream<CholoUser?> userChanges() async* {
    yield* _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _db.doc(user.uid).get();
      if (!doc.exists) return null;
      return CholoUser.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    });
  }

  Future<CholoUser> register({
    required String name,
    required String email,
    required String password,
    required String universityEmail,
  }) async {
    try {
      // Debug info about current Firebase app/options (helps diagnose web config issues)
      // ignore: avoid_print
      if (Firebase.apps.isNotEmpty) {
        print('[AuthService] Attempt register email=$email appId=${Firebase.app().options.appId} project=${Firebase.app().options.projectId}');
      } else {
        print('[AuthService] Attempt register but Firebase not initialized yet');
      }
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user!.sendEmailVerification();
      final user = CholoUser(
        id: cred.user!.uid,
        name: name,
        email: email,
        universityEmail: universityEmail,
        emailVerified: cred.user!.emailVerified,
        isAdmin: false,
      );
      await _db.doc(user.id).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e, st) {
      // ignore: avoid_print
      print('[AuthService][FirebaseAuthException] code=${e.code} message=${e.message}\n$st');
      rethrow; // let UI show e.message
    } catch (e, st) {
      // ignore: avoid_print
      print('[AuthService][UnknownError] $e\n$st');
      rethrow;
    }
  }

  Future<CholoUser?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await cred.user!.reload();
    final doc = await _db.doc(cred.user!.uid).get();
    if (!doc.exists) return null;
    final current = CholoUser.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    if (cred.user!.emailVerified && !current.emailVerified) {
      await _db.doc(current.id).update({'emailVerified': true});
      return current.copyWith(emailVerified: true);
    }
    return current;
  }

  Future<void> sendVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> logout() async => _auth.signOut();
}
