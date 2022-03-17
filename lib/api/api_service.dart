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

  /// logout
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
    String? channelId,
    int maxResults = 50,
    String? order,
    String? pageToken,
    String? query,
    List<String>? type,
  }) async {
    final youTubeApi = await getYouTubeApi();
    final SearchListResponse response = await youTubeApi.search.list(
      ['snippet'],
      channelId: channelId,
      maxResults: maxResults,
      order: order,
      pageToken: pageToken,
      q: query,
      type: type,
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

  /// get video rating
  Future<VideoGetRatingResponse> getVideoRating({required List<String> ids,}) async {
    final youTubeApi = await getYouTubeApi();
    final VideoGetRatingResponse response = await youTubeApi.videos.getRating(ids);
    return response;
  }

  /// rate video
  Future<void> rateVideo({required String id, required String rating}) async {
    final youTubeApi = await getYouTubeApi();
    await youTubeApi.videos.rate(id, rating);
  }

  /// get channels by channel id
  Future<ChannelListResponse> getChannelResponse({
    List<String>? ids,
    bool? mine,
  }) async {
    final youTubeApi = await getYouTubeApi();
    final ChannelListResponse response = await youTubeApi.channels.list(
      ['snippet', 'contentDetails', 'statistics', 'brandingSettings'],
      id: ids,
      maxResults: ids?.length,
      mine: mine,
    );
    return response;
  }

  /// get playlist item by playlist id
  Future<PlaylistItemListResponse> getPlaylistItemResponse({
    required String id,
    int maxResults = 30,
    String pageToken = '',
  }) async {
    final youTubeApi = await getYouTubeApi();
    final PlaylistItemListResponse response = await youTubeApi.playlistItems.list(
      ['snippet', 'contentDetails'],
      maxResults: maxResults,
      pageToken: pageToken,
      playlistId: id,
    );
    return response;
  }

  /// get playlist
  Future<PlaylistListResponse> getPlaylistResponse({
    String? channelId,
    List<String>? ids,
    int maxResults = 30,
    bool? mine,
    String? pageToken,
  }) async {
    final youTubeApi = await getYouTubeApi();
    final PlaylistListResponse response = await youTubeApi.playlists.list(
      ['snippet', 'contentDetails'],
      channelId: channelId,
      id: ids,
      maxResults: maxResults,
      mine: mine,
      pageToken: pageToken,
    );
    return response;
  }

  /// get login user's subscription
  Future<SubscriptionListResponse> getSubscriptionResponse({
    String? forChannelId,
    int maxResults = 50,
    String? order = 'alphabetical',
    String? pageToken,
  }) async {
    final youTubeApi = await getYouTubeApi();
    final SubscriptionListResponse response = await youTubeApi.subscriptions.list(
      ['snippet', 'contentDetails'],
      forChannelId: forChannelId,
      maxResults: maxResults,
      mine: true,
      order: order,
      pageToken: pageToken,
    );
    return response;
  }

  /// insert subscription
  Future<Subscription> insertSubscription({
    required Channel channel,
  }) async {
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
  }

  /// delete subscription
  Future<void> deleteSubscription({
    required Subscription subscription,
  }) async {
    final youTubeApi = await getYouTubeApi();
    await youTubeApi.subscriptions.delete(subscription.id!);
  }
}
