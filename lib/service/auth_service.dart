// import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthService {
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: [
//       'email',
//       'https://mail.google.com/',
//     ],
//   );

//   Future<GoogleSignInAccount?> signInWithGoogle() async {
//     try {
//       // 2. Trigger the authentication flow
//       final GoogleSignInAccount? account = await _googleSignIn.signIn();
//       if(account!=null){
//         log(  'Google Sign-In successful: ${account.email}');
//          final GoogleSignInAuthentication googleAuth = await account.authentication;
//         final String? accessToken = googleAuth.accessToken;
//         log("============================================");
//         log(accessToken.toString());
//       }else{
//         log("User cancelled the Google Sign-In");
//       }
//       return account;
//     }on FirebaseAuthException catch (e) {
//       log('Firebase Exception during Google Sign-In: ${e.message}');
//       return null;
//     }

//     catch (error) {
//       log('Google Sign-In failed: $error');
//       return null;
//     }
//   }

//   /// Signs the current user out.
//   Future<void> signOut() async {
//     try {
//       await _googleSignIn.disconnect();
//     } catch (error) {
//       log('Google Sign-Out failed: $error');
//     }
//   }
// }

import 'dart:developer';

import 'package:email_app/service/token_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final tokenService = TokenService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://mail.google.com/'],
  );

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        log("User cancelled the Google Sign-In");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // final AuthCredential credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );
      log("Access Token: ${googleAuth.accessToken}");
      await tokenService.saveAccessToken(googleAuth.accessToken ?? '');

      // final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      // final User? user = userCredential.user;

      // if (user != null) {
      //   log('Firebase Sign-In successful. UID: ${user.uid}');
      // }

      return googleUser;
    } on FirebaseAuthException catch (e) {
      log('Firebase Exception during Google Sign-In: ${e.message}');
      return null;
    } catch (error) {
      log('An error occurred during Google Sign-In: $error');
      return null;
    }
  }

  Future<GoogleSignInAccount?> getCurrentUser() async {
    log("============================================");

    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account != null) {
        log("Current User: ${account.displayName}");
        log("Current User Email: ${account.email}");
        log("Current User Photo: ${account.photoUrl}");
        return account;
      } else {
        log("No user signed in (signInSilently returned null).");
        return null;
      }
    } catch (error) {
      log("Error in getCurrentUser (signInSilently): $error");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      log('User signed out successfully.');
    } catch (error) {
      log('Google Sign-Out failed: $error');
    }
  }

  Future<String?> getCurrentUserUid() async {
    return _firebaseAuth.currentUser?.uid;
  }
}
