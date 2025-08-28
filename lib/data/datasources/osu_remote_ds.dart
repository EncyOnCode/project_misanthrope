import 'dart:convert';
import '../../core/http_client.dart';
import '../../core/logger.dart';
import '../../core/errors.dart';

class OsuRemoteDs {
  OsuRemoteDs({required this.http, required this.tokenProvider});

  static const _base = 'https://osu.ppy.sh/api/v2';
  final IHttpClient http;
  final Future<String> Function() tokenProvider;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final token = await tokenProvider();
    final uri = Uri.parse('$_base$path').replace(queryParameters: query);
    Log.i('HTTP GET $uri');
    final (status, _, body) = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    Log.i('HTTP GET $status $uri');
    if (status != 200) throw NetworkException(status, body, uri);
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final token = await tokenProvider();
    final uri = Uri.parse('$_base$path').replace(queryParameters: query);
    Log.i('HTTP GET(list) $uri');
    final (status, _, body) = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    Log.i('HTTP GET(list) $status $uri');
    if (status != 200) throw NetworkException(status, body, uri);
    return jsonDecode(body) as List<dynamic>;
  }

  Future<Map<String, Object?>> postJson(
    String path, {
    required Map<String, Object?> body,
    Map<String, String>? query,
  }) async {
    final token = await tokenProvider();
    final uri = Uri.parse('$_base$path').replace(queryParameters: query);
    Log.i('HTTP POST $uri body=${jsonEncode(body)}');
    final (status, _, resp) = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    Log.i('HTTP POST $status $uri');
    if (status != 200) throw NetworkException(status, resp, uri);
    return (jsonDecode(resp) as Map).cast<String, Object?>();
  }
}
