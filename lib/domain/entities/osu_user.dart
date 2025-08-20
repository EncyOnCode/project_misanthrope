class OsuUser {
  OsuUser({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.countryCode,
    this.pp,
    this.globalRank,
    this.countryRank,
    this.accuracy,
    this.playCount,
  });

  final int id;
  final String username;
  final String? avatarUrl;
  final String? countryCode;
  final double? pp;
  final int? globalRank;
  final int? countryRank;
  final double? accuracy;
  final int? playCount;
}
