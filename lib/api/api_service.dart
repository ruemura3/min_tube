import 'dart:developer';

import 'package:googleapis/youtube/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

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

  /// current user
  GoogleSignInAccount? _user = googleSignIn.currentUser;

  /// get login user
  /// return null when user isn't logged in
  Future<GoogleSignInAccount?> get user async {
    if (_user == null) {
      _user = await googleSignIn.signInSilently();
    }
    return _user;
  }

  /// login
  Future<GoogleSignInAccount?> logIn() async {
    _user = await googleSignIn.signIn();
    return _user;
  }

  /// get YouTube api
  getYouTubeApi() async {
    final httpClient = await ApiService.googleSignIn.authenticatedClient();
    assert(httpClient != null, 'Authenticated client missing!');
    return YouTubeApi(httpClient!);
  }

  /// search with query
  Future<SearchListResponse> searchWithQuery(String query, [String pageToken = '']) async {
    final youTubeApi = await getYouTubeApi();
    final SearchListResponse response = await youTubeApi.search.list(
      ['snippet'],
      maxResults: 10,
      pageToken: pageToken,
      q: query,
    );
    return response;
  }

  Future<void> _getLikedList() async {
    final youTubeApi = await getYouTubeApi();
    final PlaylistItemListResponse response = await youTubeApi.playlistItems.list(
      ['snippet'],
      playlistId: 'LL', // Liked List
    );
  }
}
