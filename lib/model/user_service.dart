import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserService {
  GoogleSignInAccount? _currentUser;
  
  GoogleSignInAccount? get currentUser => _currentUser;
  final user = FirebaseAuth.instance.currentUser;
  
  bool get isLoggedIn => _currentUser != null;
  
  void setUser(GoogleSignInAccount? user) {
    _currentUser = user;
  }
  
  void logout() {
    _currentUser = null;
  }
  
  String? get userEmail => user?.email;
  String? get userName => user?.displayName;
  String? get userPhotoUrl => user?.photoURL;
}

