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
      YouTubeApi.youtubeScope,
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

  /// get youtube api
  getYouTubeApi() async {
    final httpClient = await ApiService.googleSignIn.authenticatedClient();
    return YouTubeApi(httpClient!);
  }

  /// get search resources by query
  Future<SearchListResponse> getSearchListResponse(String query, [String pageToken = '']) async {
    final youTubeApi = await getYouTubeApi();
    final SearchListResponse response = await youTubeApi.search.list(
      ['snippet'],
      maxResults: 8,
      pageToken: pageToken,
      q: query,
    );
    return response;
  }

  /// get video detail by video id
  Future<Video> getVideo(String id) async {
    final youTubeApi = await getYouTubeApi();
    final VideoListResponse response = await youTubeApi.videos.list(
      ['snippet', 'contentDetails', 'statistics', 'liveStreamingDetails'],
      id: [id],
    );
    return response.items![0];
  }

  /// get channel detail by channel id
  Future<Channel> getChannel(String id) async {
    final youTubeApi = await getYouTubeApi();
    final ChannelListResponse response = await youTubeApi.channels.list(
      ['snippet', 'contentDetails', 'statistics'],
      id: [id]
    );
    return response.items![0];
  }

  /// get playlist items resource by playlist id
  Future<PlaylistItemListResponse> getPlaylistItemsListResponse(String playlistId, [String pageToken = '']) async {
    final youTubeApi = await getYouTubeApi();
    final PlaylistItemListResponse response = await youTubeApi.playlistItems.list(
      ['snippet', 'contentDetails'],
      maxResults: 8,
      pageToken: pageToken,
      playlistId: playlistId,
    );
    return response;
  }

  /// get user's subscriptions resource
  Future<SubscriptionListResponse> getSubscriptionsResource([String pageToken = '']) async {
    final youTubeApi = await getYouTubeApi();
    final SubscriptionListResponse response = await youTubeApi.subscriptions.list(
      ['snippet', 'contentDetails'],
      maxResults: 8,
      mine: true,
      pageToken: pageToken,
    );
    return response;
  }
}
