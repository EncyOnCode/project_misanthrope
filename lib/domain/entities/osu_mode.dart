enum OsuMode {
  osu,
  taiko,
  fruits,
  mania;

  String get api => name;

  static OsuMode parse(String s) =>
      OsuMode.values.firstWhere((e) => e.name == s, orElse: () => OsuMode.osu);
}
