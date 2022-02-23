import 'dart:developer';

import 'package:googleapis/youtube/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ApiService {
  // singleton instance
  ApiService._instantiate();
  static final ApiService instance = ApiService._instantiate();

  // google_sign_in instance
  static final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      YouTubeApi.youtubeReadonlyScope,
    ],
  );

  // login user
  GoogleSignInAccount? _user = googleSignIn.currentUser;
  setUser() async {
    _user = await googleSignIn.signIn();
  }
  GoogleSignInAccount? getUser() {
    return _user;
  }
}
