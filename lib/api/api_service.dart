import 'dart:developer';

import 'package:googleapis/youtube/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// api service class
class ApiService {
  /// private constructor
  ApiService._instantiate();
  
  /// singleton instance
  static final ApiService instance = ApiService._instantiate();

  /// google_sign_in instance
  static final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      YouTubeApi.youtubeReadonlyScope,
    ],
  );

  /// get login user
  /// return null when user isn't logged in
  Future<GoogleSignInAccount?> get user async {
    GoogleSignInAccount? user = googleSignIn.currentUser;
    if (user == null) {
      user = await googleSignIn.signInSilently();
    }
    return user;
  }

  /// login
  Future<GoogleSignInAccount?> logIn() async {
    return await googleSignIn.signIn();
  }
}
