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
    required String personalEmail,
    required String universityEmail,
    required String password,
  }) async {
    try {
      // Debug info about current Firebase app/options (helps diagnose web config issues)
      // ignore: avoid_print
      if (Firebase.apps.isNotEmpty) {
        print('[AuthService] Attempt register personalEmail=$personalEmail universityEmail=$universityEmail appId=${Firebase.app().options.appId} project=${Firebase.app().options.projectId}');
      } else {
        print('[AuthService] Attempt register but Firebase not initialized yet');
      }
      
      // Create user with personal email (for login)
      final cred = await _auth.createUserWithEmailAndPassword(
        email: personalEmail, 
        password: password,
      );
      
      print('[AuthService] User created successfully: ${cred.user!.uid}');
      print('[AuthService] Personal Email: ${cred.user!.email}');
      print('[AuthService] University Email: $universityEmail');
      print('[AuthService] Email verified: ${cred.user!.emailVerified}');
      
      // Send email verification
      try {
        print('[AuthService] 📧 Attempting to send verification email...');
        print('[AuthService] User object: ${cred.user}');
        print('[AuthService] User null? ${cred.user == null}');
        
        await cred.user!.sendEmailVerification();
        
        print('[AuthService] ✅ sendEmailVerification() completed successfully');
        print('[AuthService] ✅ Verification email should be sent to: $personalEmail');
        print('[AuthService] 📬 Check inbox and spam folder');
      } catch (emailError) {
        print('[AuthService] ❌ Failed to send verification email');
        print('[AuthService] Error type: ${emailError.runtimeType}');
        print('[AuthService] Error details: $emailError');
        if (emailError is FirebaseAuthException) {
          print('[AuthService] Firebase error code: ${emailError.code}');
          print('[AuthService] Firebase error message: ${emailError.message}');
        }
        // Don't throw here - account is created, just email failed
      }
      
      final user = CholoUser(
        id: cred.user!.uid,
        name: name,
        email: personalEmail,
        universityEmail: universityEmail,
        isAdmin: false,
      );
      await _db.doc(user.id).set(user.toMap());
      
      // Sign out user immediately so they must verify email before logging in
      await _auth.signOut();
      print('[AuthService] User signed out after registration');
      
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
    
    // Check if email is verified
    if (!cred.user!.emailVerified) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before logging in. Check your inbox for the verification link.',
      );
    }
    
    final doc = await _db.doc(cred.user!.uid).get();
    if (!doc.exists) return null;
    final current = CholoUser.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    return current;
  }
  
  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      // Sign in temporarily to get user object
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await cred.user!.reload();
      
      if (!cred.user!.emailVerified) {
        await cred.user!.sendEmailVerification();
      }
      
      // Sign out again
      await _auth.signOut();
    } catch (e) {
      print('[AuthService] Error resending verification: $e');
      rethrow;
    }
  }

  Future<void> logout() async => _auth.signOut();
}
