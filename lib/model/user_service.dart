import 'package:google_sign_in/google_sign_in.dart';

class UserService {
  GoogleSignInAccount? _currentUser;
  
  GoogleSignInAccount? get currentUser => _currentUser;
  
  bool get isLoggedIn => _currentUser != null;
  
  void setUser(GoogleSignInAccount? user) {
    _currentUser = user;
  }
  
  void logout() {
    _currentUser = null;
  }
  
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;
  String? get userPhotoUrl => _currentUser?.photoUrl;
}

