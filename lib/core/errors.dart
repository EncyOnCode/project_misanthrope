class NetworkException implements Exception {
  NetworkException(this.statusCode, this.body, this.uri);

  final int statusCode;
  final String body;
  final Uri uri;

  @override
  String toString() => 'HTTP $statusCode on $uri: $body';
}
