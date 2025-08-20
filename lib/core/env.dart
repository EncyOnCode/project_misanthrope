class Env {

  factory Env.fromPlatform(Map<String, String> env) {
    final bot = env['BOT_TOKEN'];
    final id = env['OSU_CLIENT_ID'];
    final secret = env['OSU_CLIENT_SECRET'];
    if (bot == null || id == null || secret == null) {
      throw ArgumentError(
        'Set env: BOT_TOKEN, OSU_CLIENT_ID, OSU_CLIENT_SECRET',
      );
    }
    return Env(botToken: bot, osuClientId: id, osuClientSecret: secret);
  }
  Env({
    required this.botToken,
    required this.osuClientId,
    required this.osuClientSecret,
  });

  final String botToken;
  final String osuClientId;
  final String osuClientSecret;
}
