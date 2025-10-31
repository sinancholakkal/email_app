import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class TokenService {
  final accessTokenKey = 'accessToken';
  final storage = FlutterSecureStorage();
   final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://mail.google.com/',
    ],
  );
  Future<void> saveAccessToken(String accessToken) async {
    await storage.write(key: accessTokenKey, value: accessToken);
    

  }
  // Future<String?> getAccessToken() async {
  //   final token = await storage.read(key: accessTokenKey);
  //   log("Token: $token");
  //   return token;
  // }
  // Future<String?> getAccessToken() async {
  //   String? storedToken = await storage.read(key: accessTokenKey);

  //   // --- CALL IT HERE ---
  //   // Try to silently refresh the token before returning it.
  //   log("Attempting silent sign-in to potentially refresh token...");
  //   try {
  //     final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
  //     if (account != null) {
  //       final auth = await account.authentication;
  //       final newAccessToken = auth.accessToken;
  //       if (newAccessToken != null) {
  //         log("Silent sign-in successful. Using potentially refreshed token.");
  //         // Save the potentially new token
  //          log("Olde access token $storedToken");
  //           log("New access token $newAccessToken");
  //         if (newAccessToken != storedToken) {
  //          log("New access token and old access token are different");
  //           await deleteAccessToken();
  //             await saveAccessToken(newAccessToken);
  //         }
  //         return newAccessToken; // Return the fresh token
  //       }
  //     } else {
  //       log("Account is null");
  //        log("Silent sign-in returned null account, user might be signed out.");
  //        // If silent sign-in fails completely, clear stored token
  //        await deleteAccessToken();
  //        return null;
  //     }
  //   } catch (e) {
  //     log("Silent sign-in failed (might need full sign-in): $e");
  //     // If error, proceed cautiously with the old token or handle as needed
  //     // Depending on the error, you might want to clear the token here too.
  //   }

  //   // Fallback: return the stored token if refresh attempt failed but didn't clear it
  //   log("Returning stored token (might be expired).");
  //   return storedToken;
  // }

  Future<String?> getAccessToken({int retryCount = 2}) async {
  String? storedToken = await storage.read(key: accessTokenKey);

  for (int attempt = 0; attempt < retryCount; attempt++) {
    log("Attempting silent sign-in (attempt ${attempt + 1})...");
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        final newAccessToken = auth.accessToken;
        if (newAccessToken != null) {
          log("Silent sign-in successful. Using potentially refreshed token.");
          if (newAccessToken != storedToken) {
            await deleteAccessToken();
            await saveAccessToken(newAccessToken);
          }
          return newAccessToken;
        }
      } else {
        log("Silent sign-in returned null account, user might be signed out.");
        await Future.delayed(const Duration(seconds: 1)); // Wait and retry
      }
    } catch (e) {
      log("Silent sign-in failed: $e");
      break;
    }
  }

  // If still no account, clear token and return null
  await deleteAccessToken();
  return null;
}
  Future<void> deleteAccessToken() async {
    await storage.delete(key: accessTokenKey);
  }
}