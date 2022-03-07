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
    try {
      final youTubeApi = await getYouTubeApi();
      final SearchListResponse response = await youTubeApi.search.list(
        ['snippet'],
        channelId: channelId,
        order: order,
        pageToken: pageToken,
        q: query,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

  /// get videos by video ids
  Future<VideoListResponse> getVideoResponse({required List<String> ids,}) async {
    try {
      final youTubeApi = await getYouTubeApi();
      final VideoListResponse response = await youTubeApi.videos.list(
        ['snippet', 'contentDetails', 'statistics', 'liveStreamingDetails'],
        id: ids,
        maxResults: ids.length,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

  /// get channels by channel id
  Future<ChannelListResponse> getChannelResponse({required List<String> ids,}) async {
    try {
      final youTubeApi = await getYouTubeApi();
      final ChannelListResponse response = await youTubeApi.channels.list(
        ['snippet', 'contentDetails', 'statistics', 'brandingSettings'],
        id: ids,
        maxResults: ids.length,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

  /// get playlist item by playlist id
  Future<PlaylistItemListResponse> getPlaylistItemResponse({
    required String id,
    String pageToken = '',
  }) async {
    try {
      final youTubeApi = await getYouTubeApi();
      final PlaylistItemListResponse response = await youTubeApi.playlistItems.list(
        ['snippet', 'contentDetails'],
        maxResults: 8,
        pageToken: pageToken,
        playlistId: id,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

  /// get playlist by channel id
  Future<PlaylistListResponse> getPlaylistResponse({
    required String id,
    String pageToken = '',
  }) async {
    try {
      final youTubeApi = await getYouTubeApi();
      final PlaylistListResponse response = await youTubeApi.playlists.list(
        ['snippet', 'contentDetails'],
        channelId: id,
        maxResults: 8,
        pageToken: pageToken,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

  /// get login user's subscription
  Future<SubscriptionListResponse> getSubscriptionResponse({
    String forChannelId = '',
    String order = 'unread',
    String pageToken = ''
  }) async {
    try {
      final youTubeApi = await getYouTubeApi();
      final SubscriptionListResponse response = await youTubeApi.subscriptions.list(
        ['snippet', 'contentDetails'],
        forChannelId: forChannelId,
        maxResults: 10,
        mine: true,
        order: order,
        pageToken: pageToken,
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

  /// insert subscription
  Future<Subscription> insertSubscription({
    required Channel channel,
  }) async {
    try {
      final youTubeApi = await getYouTubeApi();
      final response = await youTubeApi.subscriptions.insert(
        Subscription(
          snippet: SubscriptionSnippet(
            resourceId: ResourceId(channelId: channel.id)
          ),
        ),
        ['snippet'],
      );
      return response;
    } catch (e) {
      throw e;
    }
  }

  /// delete subscription
  Future<void> deleteSubscription({
    required Subscription subscription,
  }) async {
    try {
      final youTubeApi = await getYouTubeApi();
      await youTubeApi.subscriptions.delete(subscription.id!);
    } catch (e) {
      throw e;
    }
  }
}
