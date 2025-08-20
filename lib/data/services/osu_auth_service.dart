import 'dart:convert';
import '../../core/http_client.dart';

class OsuAuthService {
  OsuAuthService({
    required this.http,
    required this.clientId,
    required this.clientSecret,
  });

  static const _tokenUrl = 'https://osu.ppy.sh/oauth/token';
  final IHttpClient http;
  final String clientId;
  final String clientSecret;
  String? _accessToken;
  DateTime _expiresAt = DateTime.fromMillisecondsSinceEpoch(0);

  Future<String> getToken() async {
    final now = DateTime.now();
    if (_accessToken != null &&
        now.isBefore(_expiresAt.subtract(const Duration(minutes: 1)))) {
      return _accessToken!;
    }
    final (status, _, body) = await http.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'client_credentials',
        'scope': 'public',
      },
    );
    if (status != 200) throw Exception('osu! token error: $status $body');
    final json = jsonDecode(body) as Map<String, dynamic>;
    _accessToken = json['access_token'] as String;
    final expiresIn = (json['expires_in'] as num?)?.toInt() ?? 3600;
    _expiresAt = now.add(Duration(seconds: expiresIn));
    return _accessToken!;
  }
}
