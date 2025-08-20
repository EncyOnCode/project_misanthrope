import 'package:http/http.dart' as http;

abstract class IHttpClient {
  Future<(int status, Map<String, String> headers, String body)> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  });

  Future<(int status, Map<String, String> headers, String body)> get(
    Uri uri, {
    Map<String, String>? headers,
  });
}

class HttpClientImpl implements IHttpClient {

  HttpClientImpl(this._c);
  final http.Client _c;

  @override
  Future<(int, Map<String, String>, String)> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final r = await _c.post(uri, headers: headers, body: body);
    return (r.statusCode, r.headers.map(MapEntry.new), r.body);
  }

  @override
  Future<(int, Map<String, String>, String)> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final r = await _c.get(uri, headers: headers);
    return (r.statusCode, r.headers.map(MapEntry.new), r.body);
  }
}
