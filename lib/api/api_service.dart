import 'package:googleapis/youtube/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

/// api service
class ApiService {
  /// private constructor
  ApiService._instantiate();

  /// singleton instance
  static final ApiService instance = ApiService._instantiate();

  /// google sign in instance
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      // YouTubeApi.youtubeReadonlyScope,
      YouTubeApi.youtubeScope,
    ],
  );

  /// current user
  GoogleSignInAccount? _user = _googleSignIn.currentUser;

  /// get login user
  /// return null when user isn't logged in
  Future<GoogleSignInAccount?> get user async {
    if (_user == null) {
      _user = await _googleSignIn.signInSilently();
    }
    return _user;
  }

  /// login
  Future<GoogleSignInAccount?> login() async {
    _user = await _googleSignIn.signIn();
    return _user;
  }

  /// login
  Future<GoogleSignInAccount?> logout() async {
    await _googleSignIn.signOut();
    _user = null;
  }

  /// get youtube api
  Future<YouTubeApi> getYouTubeApi() async {
    final httpClient = await _googleSignIn.authenticatedClient();
    return YouTubeApi(httpClient!);
  }

  /// get search response
  Future<SearchListResponse> getSearchResponse({
    String channelId = '',
    String order = 'relevance',
    String pageToken = '',
    String query = '',
  }) async {
    final youTubeApi = await getYouTubeApi();
    final SearchListResponse response = await youTubeApi.search.list(
      ['snippet'],
      channelId: channelId,
      order: order,
      pageToken: pageToken,
      q: query,
    );
    return response;
  }

  /// get videos by video ids
  Future<VideoListResponse> getVideoResponse({required List<String> ids,}) async {
    final youTubeApi = await getYouTubeApi();
    final VideoListResponse response = await youTubeApi.videos.list(
      ['snippet', 'contentDetails', 'statistics', 'liveStreamingDetails'],
      id: ids,
      maxResults: ids.length,
    );
    return response;
  }

  /// get channels by channel id
  Future<ChannelListResponse> getChannelResponse({required List<String> ids,}) async {
    final youTubeApi = await getYouTubeApi();
    final ChannelListResponse response = await youTubeApi.channels.list(
      ['snippet', 'contentDetails', 'statistics', 'brandingSettings'],
      id: ids,
      maxResults: ids.length,
    );
    return response;
  }

  /// get playlist item by playlist id
  Future<PlaylistItemListResponse> getPlaylistItemResponse({
    required String id,
    String pageToken = '',
  }) async {
    final youTubeApi = await getYouTubeApi();
    final PlaylistItemListResponse response = await youTubeApi.playlistItems.list(
      ['snippet', 'contentDetails'],
      maxResults: 8,
      pageToken: pageToken,
      playlistId: id,
    );
    return response;
  }

  /// get playlist by channel id
  Future<PlaylistListResponse> getPlaylistResponse({
    required String id,
    String pageToken = '',
  }) async {
    final youTubeApi = await getYouTubeApi();
    final PlaylistListResponse response = await youTubeApi.playlists.list(
      ['snippet', 'contentDetails'],
      channelId: id,
      maxResults: 8,
      pageToken: pageToken,
    );
    return response;
  }

  /// get login user's subscription
  Future<SubscriptionListResponse> getSubscriptionResponse({String pageToken = ''}) async {
    final youTubeApi = await getYouTubeApi();
    final SubscriptionListResponse response = await youTubeApi.subscriptions.list(
      ['snippet', 'contentDetails'],
      mine: true,
      pageToken: pageToken,
    );
    return response;
  }
}
