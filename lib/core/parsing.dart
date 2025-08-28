({String user, String mode}) parseArgs(
  String? text, {
  String defaultMode = 'osu',
}) {
  final parts = (text ?? '').trim().split(RegExp(r'\s+'));
  if (parts.length < 2) return (user: '', mode: defaultMode);
  final args = parts.sublist(1);
  final modes = {'osu', 'taiko', 'fruits', 'mania'};
  var mode = defaultMode;
  if (args.isNotEmpty && modes.contains(args.last.toLowerCase())) {
    mode = args.removeLast().toLowerCase();
  }
  return (user: args.join(' ').trim(), mode: mode);
}

bool matchAlias(String? text, String alias, String botUsername) {
  if (text == null) return false;
  final t = text.trim().toLowerCase();
  if (!t.startsWith('/')) return false;
  final a = alias.toLowerCase();
  final withAt = '/$a@${botUsername.toLowerCase()}';
  return t == '/$a' ||
      t.startsWith('/$a ') ||
      t == withAt ||
      t.startsWith('$withAt ');
}

/// Tries to extract a beatmap id from arbitrary text: accepts
/// - direct ids (digits)
/// - links like:
///   - https://osu.ppy.sh/beatmaps/{id}
///   - https://osu.ppy.sh/b/{id}
///   - https://osu.ppy.sh/beatmapsets/{set}#mode/{id}
int? extractBeatmapId(String? text) {
  if (text == null || text.trim().isEmpty) return null;
  final t = text.trim();

  // Do not accept a raw numeric id from the command text anymore.

  // Prefer beatmapsets links that include a difficulty id after the hash.
  final setWithDiff = RegExp(
    r'osu\.ppy\.sh/beatmapsets/\d+#[^/\s]+/(\d+)',
    caseSensitive: false,
  );
  final sMatch = setWithDiff.firstMatch(t);
  if (sMatch != null && sMatch.groupCount >= 1) {
    return int.tryParse(sMatch.group(1)!);
  }

  // Other direct beatmap link patterns.
  final patterns = <RegExp>[
    RegExp(r'osu\.ppy\.sh/beatmaps/(\d+)', caseSensitive: false),
    RegExp(r'osu\.ppy\.sh/b/(\d+)', caseSensitive: false),
  ];
  for (final re in patterns) {
    final m = re.firstMatch(t);
    if (m != null && m.groupCount >= 1) {
      return int.tryParse(m.group(1)!);
    }
  }

  return null;
}

extension on Iterable<String> {
}
